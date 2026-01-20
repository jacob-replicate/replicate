require "rails_helper"

RSpec.describe "TopicsController", type: :request do
  let(:topic) { create(:topic) }

  describe "POST /:code/populate" do
    context "when user is admin (via IP)" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("98.249.45.68")
      end

      it "enqueues PopulateTopicWorker and redirects" do
        expect(PopulateTopicWorker).to receive(:perform_async).with(topic.id)

        post populate_topic_path(topic.code)

        expect(response).to redirect_to(topic_path(topic.code))
      end
    end

    context "when user is admin (via development env)" do
      it "enqueues PopulateTopicWorker and redirects" do
        expect(Rails.env).to receive(:development?).at_least(:once).and_return(true)
        expect(PopulateTopicWorker).to receive(:perform_async).with(topic.id)

        post populate_topic_path(topic.code)

        expect(response).to redirect_to(topic_path(topic.code))
      end
    end

    context "when user is not admin" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("192.168.1.1")
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it "raises an error" do
        expect {
          post populate_topic_path(topic.code)
        }.to raise_error(RuntimeError, "Not found")
      end
    end

    context "when topic does not exist" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("98.249.45.68")
      end

      it "returns a 404" do
        post "/nonexistent/populate"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /:code" do
    context "when topic has experiences" do
      let!(:experience) { create(:experience, topic: topic, template: true) }

      it "redirects to a random experience on first visit" do
        get topic_path(topic.code)

        expect(response).to redirect_to(topic_experience_path(topic.code, experience.code))
      end

      it "shows the topic page when user has forked experiences" do
        # Use a fixed session identifier for this test
        fixed_session_id = "test_session_12345"
        allow_any_instance_of(ApplicationController).to receive(:set_session_identifier) do |controller|
          controller.session[:identifier] = fixed_session_id
        end

        # Create a forked experience for this session
        create(:experience, topic: topic, template: false, code: experience.code, session_id: fixed_session_id)

        get topic_path(topic.code)


        expect(response).to have_http_status(:ok)
        expect(response.body).to include(experience.name)
      end
    end

    context "when topic has no experiences" do
      it "shows the empty state" do
        get topic_path(topic.code)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("No experiences yet")
      end
    end
  end
end