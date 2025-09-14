require "rails_helper"

RSpec.describe CreateIncidentWorker, type: :worker do
  subject(:worker) { described_class.new }
  let(:organization) { create(:organization, access_end_date: 1.month.from_now) }
  let(:member)       { create(:member, organization: organization, subscribed: true) }

  let(:incident) do
    {
      "prompt" => "Database writes intermittently fail due to replica lag. Walk me through your first 3 checks.",
      "subject" => "Replica lag causing write flaps"
    }
  end

  describe "#perform" do
    context "when the member does not exist" do
      it "returns without creating a conversation" do
        expect(Conversation).not_to receive(:create!)
        worker.perform(-1, incident)
      end
    end

    context "when the member is not subscribed" do
      it "returns without creating a conversation" do
        member.update(subscribed: false)
        expect(Conversation).not_to receive(:create!)
        worker.perform(member.id, incident)
      end
    end

    context "when the organization is inactive" do
      it "returns without creating a conversation" do
        organization.update!(access_end_date: 5.days.ago)
        expect(Conversation).not_to receive(:create!)
        worker.perform(member.id, incident)
      end
    end

    context "when the member has a conversation in the last 24 hours" do
      it "returns without creating a new conversation" do
        create(:conversation, recipient: member, created_at: 2.hours.ago)
        expect(Conversation).not_to receive(:create!)
        worker.perform(member.id, incident)
      end
    end

    context "trial members" do
      it "creates the first 4 conversations, then pauses until activity" do
        Timecop.freeze do
          new_member = create(:member, organization: organization, subscribed: true, created_at: 2.weeks.ago)
          allow_any_instance_of(Prompts::Base).to receive(:fetch_raw_output).and_return("Imagine a status page shows read replica lag at 15ms for a week straight. Query durations spike briefly after large write operations, but dashboards for writes, reads, and connection pools all stay green.")

          4.times do |i|
            expect { worker.perform(new_member.id, incident) }.to change { Conversation.count }.by(1)
            expect(new_member.conversations.count).to eq(i + 1)
            Conversation.update_all(created_at: 1.week.ago)
          end

          expect { worker.perform(new_member.id, incident) }.to change { Conversation.count }.by(0)
          create(:message, conversation: new_member.conversations.last, user_generated: true, created_at: 2.weeks.ago)
          expect { worker.perform(new_member.id, incident) }.to change { Conversation.count }.by(1)
        end
      end
    end

    context "when all preconditions pass" do
      it "creates a conversation with the expected attributes and runs the driver worker" do
        old_conversation = create(:conversation, recipient: member, created_at: 2.days.ago)

        driver = instance_double(ConversationDriverWorker)
        expect(ConversationDriverWorker).to receive(:new).and_return(driver)
        expect(driver).to receive(:perform) do |conversation_id|
          expect(Conversation.find(conversation_id)).to be_present
        end

        expect {
          worker.perform(member.id, incident)
        }.to change { Conversation.count }.by(1)

        conversation = Conversation.where.not(id: old_conversation.id).first
        expect(conversation.channel).to eq("email")
        expect(conversation.recipient).to eq(member)

        # context payload
        expect(conversation.context).to eq({"conversation_type" => "coaching", "incident" => incident["prompt"] })

        expect(conversation.subject_line).to eq("Replica lag causing write flaps")
      end
    end
  end
end