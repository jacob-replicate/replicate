require "rails_helper"

RSpec.describe ProcessPostmarkWebhookWorker, type: :worker do
  subject(:worker) { described_class.new }

  let!(:conversation) { create(:conversation) }
  let!(:parent_msg) do
    create(:message,
      conversation: conversation,
      content: "root",
      email_message_id_header: "<parent-123@mail.invariant.training>",
      user_generated: false
    )
  end

  describe "#perform" do
    it "returns quietly when the webhook does not exist" do
      expect { worker.perform(-999) }.not_to raise_error
    end

    context "with a real webhook record" do
      let(:payload) do
        {
          "StrippedTextReply" => "Hello from Postmark",
          "MessageID" => "pm-123",
          "Headers" => [
            { "Name" => "In-Reply-To", "Value" => "#{parent_msg.email_message_id_header}" },
            { "Name" => "Message-ID",  "Value" => "<child-456@mail.invariant.training>" }
          ]
        }
      end

      let!(:webhook) { create(:postmark_webhook, content: payload) }

      it "creates a reply message in the original conversation and marks processed" do
        expect {
          worker.perform(webhook.id)
        }.to change { conversation.messages.count }.by(1)

        new_msg = conversation.messages.order(:created_at).last
        expect(new_msg).to have_attributes(
          user_generated: true,
          content: "Hello from Postmark",
          email_message_id_header: "<child-456@mail.invariant.training>"
        )

        expect(webhook.reload.processed_at).to be_within(1.second).of(Time.current)
      end

      it "marks processed but does not create a message when no parent matches" do
        webhook.update!(content: payload.merge(
          "Headers" => [
            { "Name" => "In-Reply-To", "Value" => "<not-found@mail.invariant.training>" },
            { "Name" => "Message-ID",  "Value" => "<child-789@mail.invariant.training>" }
          ]
        ))

        expect {
          worker.perform(webhook.id)
        }.not_to change(Message, :count)

        expect(webhook.reload.processed_at).to be_present
      end

      it "does nothing when already processed and force = false" do
        webhook.update!(processed_at: 1.hour.ago)

        expect {
          worker.perform(webhook.id, false)
        }.not_to change(Message, :count)

        expect(webhook.reload.processed_at).to be_within(1.second).of(1.hour.ago)
      end

      it "processes again when force = true even if already processed" do
        webhook.update!(processed_at: 1.hour.ago)

        expect {
          worker.perform(webhook.id, true)
        }.to change { conversation.messages.count }.by(1)

        forced = conversation.messages.order(:created_at).last
        expect(forced.email_message_id_header).to eq("<child-456@mail.invariant.training>")
      end
    end
  end
end