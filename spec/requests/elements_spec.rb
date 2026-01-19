require "rails_helper"

RSpec.describe "ElementsController#show", type: :request do
  describe "GET /elements/:id" do
    context "when element already has a conversation" do
      it "redirects to the existing conversation" do
        experience = create(:experience)
        conversation = create(:conversation)
        element = create(:element, code: "incident_cta", experience: experience, conversation: conversation)

        get "/elements/#{element.id}"

        expect(response).to redirect_to("/conversations/#{conversation.id}")
      end
    end

    context "when element does not have a conversation" do
      it "creates a new conversation and redirects to it" do
        experience = create(:experience)
        element = create(:element,
          code: "incident_cta",
          experience: experience,
          conversation: nil,
          generation_intent: "Test incident for debugging",
          context: { "title" => "Test Incident" }
        )

        expect {
          get "/elements/#{element.id}"
        }.to change(Conversation, :count).by(1)

        created_conversation = Conversation.last
        expect(element.reload.conversation).to eq(created_conversation)
        expect(response).to redirect_to("/conversations/#{created_conversation.id}")
        expect(created_conversation.generation_intent).to eq("Test incident for debugging")
      end
    end

    context "when element has unsupported code" do
      it "raises ArgumentError for unknown element code" do
        experience = create(:experience)
        element = create(:element, code: "unknown_code", experience: experience, conversation: nil)

        expect {
          get "/elements/#{element.id}"
        }.to raise_error(ArgumentError, /Unknown element code/)
      end
    end
  end
end