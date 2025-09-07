require "rails_helper"

RSpec.describe ConversationMailer, type: :mailer do
  let(:recipient)    { create(:member, email: "chris@your-company.com") }
  let(:conversation) { create(:conversation, recipient: recipient, subject_line: "Admin access granted without explicit intent") }

  describe "#drive" do
    context "when this is the first message in the thread" do
      it "sets only Message-ID and omits reply headers; includes unsubscribe; prefixes subject" do
        root = create(:message, conversation: conversation, content: "<p>Hello</p>", user_generated: false)
        mail = described_class.drive(conversation)

        expect(mail.to).to eq([recipient.email])
        expect(mail.from).to eq(["loop@mail.replicate.info"])
        expect(mail.reply_to).to eq(["loop@mail.replicate.info"])
        expect(recipient.conversations.count).to eq(1)
        expect(mail.subject).to eq("[SEV-1 Training] #{conversation.subject_line}")
        expect(mail.multipart?).to be(true)
        expect(mail.content_type).to match(%r{\Amultipart/alternative;})
        expect(mail.html_part.content_type).to match(%r{\Atext/html})
        expect(mail.html_part.body.decoded).to eq(root.content)
        expect(mail.text_part.content_type).to match(%r{\Atext/plain})
        expect(mail.text_part.body.decoded).to eq(root.plain_text_content)
        expect(mail["Message-ID"].to_s).to eq(root.email_message_id_header)
        expect(mail["In-Reply-To"]).to be_nil
        expect(mail["References"]).to be_nil
        expect(mail["List-Unsubscribe"].to_s).to eq("<https://replicate.info/members/#{conversation.recipient_id}/unsubscribe>")
        expect(mail["List-Unsubscribe-Post"].to_s).to eq("List-Unsubscribe=One-Click")
      end
    end

    context "when there are prior messages in the same conversation" do
      it "threads by setting In-Reply-To to the immediate parent and References to the ordered prior chain" do
        Timecop.freeze(Time.zone.parse("2025-09-01 10:00:00")) do
          m1 = create(:message, conversation: conversation, user_generated: false, content: "m1", created_at: 3.hours.ago)
          m2 = create(:message, conversation: conversation, user_generated: true, content: "m2", created_at: 2.hours.ago)
          m2.update(email_message_id_header: "<message-#{SecureRandom.uuid}@mail.replicate.info>")
          ignored = create(:message, conversation: conversation, email_message_id_header: nil, user_generated: false, created_at: 1.hour.ago)
          ignored.update(email_message_id_header: nil)
          latest = create(:message, conversation: conversation, user_generated: false, content: "<p>root</p>", created_at: Time.current)

          mail = described_class.drive(conversation)
          prior_chain = [m1.email_message_id_header, m2.email_message_id_header].join(" ")
          expect(mail["Message-ID"].to_s).to eq(latest.email_message_id_header)
          expect(mail["References"].to_s).to eq(prior_chain)
          expect(mail["In-Reply-To"].to_s).to eq(m2.email_message_id_header)
        end
      end
    end

    context "when the recipient already has more than one conversation" do
      it "does not prefix the subject" do
        _other_conv = create(:conversation, recipient: recipient, subject_line: "older")

        root = create(:message, conversation: conversation, content: "hi")
        allow(conversation).to receive(:latest_system_message).and_return(root)

        mail = described_class.drive(conversation)
        expect(recipient.conversations.count).to be > 1
        expect(mail.subject).to eq(conversation.subject_line)
      end
    end
  end
end