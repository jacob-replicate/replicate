require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller(described_class) do
    def test_start
      start_conversation(
        initial_message: params[:initial_message],
        context: params[:context] || {},
        force_tos: params[:force_tos] == "1"
      )
    end
  end

  before do
    routes.draw do
      resources :conversations, only: [:show]
      get "test_start" => "anonymous#test_start"
    end
  end

  describe "#start_conversation" do
    before do
      stub_const("ApplicationController::EXAMPLE_EMAILS", [
        { prompt: "example-initial-message" },
        { prompt: "another-message" }
      ])
    end

    it "sets first_name from engineer_name in context" do
      get :test_start, params: { context: { "engineer_name" => "Taylor Morales" } }

      conversation = Conversation.last
      expect(conversation).to be_present
      expect(conversation.channel).to eq("web")
      expect(conversation.context["engineer_name"]).to eq("Taylor Morales")
      expect(conversation.context["first_name"]).to eq("Taylor")

      expect(response).to redirect_to(conversation_path(conversation))
      expect(controller.instance_variable_get(:@conversation)).to eq(conversation)
    end

    it "does not set first_name when engineer_name is blank or missing" do
      get :test_start, params: { context: { "engineer_name" => "" } }
      conversation_blank = Conversation.last
      expect(conversation_blank.context).not_to have_key("first_name")

      get :test_start, params: { context: {} }
      conversation_missing = Conversation.order(:created_at).last
      expect(conversation_missing.context).not_to have_key("first_name")
    end

    it "redirects with require_tos when force_tos is true" do
      get :test_start, params: { force_tos: "1", context: {} }

      conversation = Conversation.last
      expect(response).to redirect_to(conversation_path(conversation, require_tos: true))
    end

    it "redirects with require_tos when initial_message matches an EXAMPLE_EMAILS prompt" do
      get :test_start, params: { initial_message: "example-initial-message", context: {} }

      conversation = Conversation.last
      expect(response).to redirect_to(conversation_path(conversation, require_tos: true))
    end

    it "redirects without require_tos when neither force_tos nor prompt match is present" do
      get :test_start, params: { initial_message: "some other text", context: {} }

      conversation = Conversation.last
      expect(response).to redirect_to(conversation_path(conversation))
    end

    it "persists the provided context (in addition to any derived fields)" do
      context_payload = { "engineer_name" => "Casey Patel", "team" => "SRE", "env" => "prod" }
      get :test_start, params: { context: context_payload }

      conversation = Conversation.last
      expect(conversation.context.slice("engineer_name", "team", "env")).to eq(context_payload)
      expect(conversation.context["first_name"]).to eq("Casey")
    end
  end
end