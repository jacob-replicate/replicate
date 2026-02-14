require "rails_helper"

RSpec.describe "TopicsController", type: :request do
  let(:topic) { create(:topic) }

  describe "POST /:code/populate" do
    context "when user is admin (via user flag)" do
      let(:admin_user) { create(:user, :admin) }

      before do
        allow_any_instance_of(ApplicationController).to receive(:admin?).and_return(true)
      end

      it "enqueues PopulateTopicWorker and redirects" do
        expect(PopulateTopicWorker).to receive(:perform_async).with(topic.id)

        post populate_topic_path(topic.code)

        expect(response).to redirect_to(topic_path(topic.code))
      end
    end

    context "when user is not admin" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:admin?).and_return(false)
      end

      it "raises not found error" do
        expect {
          post populate_topic_path(topic.code)
        }.to raise_error(RuntimeError, "Not found")
      end
    end

    context "when topic does not exist" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:admin?).and_return(true)
      end

      it "returns a 404" do
        post "/nonexistent/populate"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /:code" do
    context "when topic has conversations" do
      let!(:conversation) { create(:conversation, topic: topic, template: true, state: "populated") }

      it "returns JSON with topic and conversation data" do
        get topic_path(topic.code)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")

        json = JSON.parse(response.body)
        expect(json["topic_state"]).to eq(topic.state)
        expect(json["conversation_count"]).to eq(1)
        expect(json["conversations"]).to be_an(Array)
        expect(json["conversations"].first["code"]).to eq(conversation.code)
      end

      it "shows completed count when user has visited conversations" do
        # Use a fixed session identifier for this test
        fixed_session_id = "test_session_12345"
        allow_any_instance_of(ApplicationController).to receive(:set_session_identifier) do |controller|
          controller.session[:identifier] = fixed_session_id
        end

        # Create a forked conversation for this session
        create(:conversation, topic: topic, template: false, code: conversation.code, owner_type: "Session", owner_id: fixed_session_id)

        get topic_path(topic.code)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["completed_count"]).to eq(1)
        expect(json["conversations"].first["visited"]).to eq(true)
      end
    end

    context "when topic has no conversations" do
      it "returns JSON with empty conversations array" do
        get topic_path(topic.code)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["conversations"]).to eq([])
        expect(json["conversation_count"]).to eq(0)
      end
    end

    context "when requesting via XHR" do
      let!(:conversation) { create(:conversation, topic: topic, template: true, state: "populated", name: "Test Conversation") }

      it "returns JSON with topic and conversation data" do
        get topic_path(topic.code), headers: { "X-Requested-With" => "XMLHttpRequest" }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")

        json = JSON.parse(response.body)
        expect(json["topic_state"]).to eq(topic.state)
        expect(json["conversation_count"]).to eq(1)
        expect(json["completed_count"]).to eq(0)
        expect(json["conversations"]).to be_an(Array)
        expect(json["conversations"].first["code"]).to eq(conversation.code)
        expect(json["conversations"].first["name"]).to eq("Test Conversation")
        expect(json["conversations"].first["state"]).to eq("populated")
        expect(json["conversations"].first["visited"]).to eq(false)
      end
    end
  end
end