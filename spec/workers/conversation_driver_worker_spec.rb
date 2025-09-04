require "rails_helper"

RSpec.describe ConversationDriverWorker, type: :worker do
  subject(:worker) { described_class.new }

  let!(:active_org)   { create(:organization, access_end_date: 1.month.from_now) }
  let!(:inactive_org) { create(:organization, access_end_date: 1.month.ago) }

  let!(:active_org_active_member)     { create(:member, organization: active_org,   subscribed: true) }
  let!(:active_org_inactive_member)   { create(:member, organization: active_org,   subscribed: false) }
  let!(:inactive_org_active_member)   { create(:member, organization: inactive_org, subscribed: true) }
  let!(:inactive_org_inactive_member) { create(:member, organization: inactive_org, subscribed: false) }

  let(:generator_instance) { instance_double("MessageGenerators::Coaching", deliver: true) }

  before do
    allow(MessageGenerators::Coaching).to receive(:new).and_return(generator_instance)
  end

  describe "#perform" do
    context "when conversation channel is email" do
      let(:channel) { "email" }

      context "active org" do
        it "drives the conversation for active members" do
          convo = create(:conversation, recipient: active_org_active_member,
            channel: channel,
            context: { "conversation_type" => "coaching" })

          expect(MessageGenerators::Coaching).to receive(:new).with(convo).and_return(generator_instance)
          expect(generator_instance).to receive(:deliver)
          worker.perform(convo.id)
        end

        it "drives the conversation for inactive members" do
          convo = create(:conversation, recipient: active_org_inactive_member,
            channel: channel,
            context: { "conversation_type" => "coaching" })

          expect(MessageGenerators::Coaching).to receive(:new).with(convo).and_return(generator_instance)
          expect(generator_instance).to receive(:deliver)
          worker.perform(convo.id)
        end

        it "does nothing when member cannot be found" do
          convo = create(:conversation, recipient: nil, channel: channel, context: { "conversation_type" => "coaching" })
          expect(MessageGenerators::Coaching).not_to receive(:new)
          worker.perform(convo.id)
        end
      end

      context "inactive org" do
        it "does not drive the conversation for any members" do
          expect(MessageGenerators::Coaching).not_to receive(:new)

          convo = create(:conversation, recipient: inactive_org_active_member, channel: channel, context: { "conversation_type" => "coaching" })
          worker.perform(convo.id)

          convo = create(:conversation, recipient: inactive_org_inactive_member, channel: channel, context: { "conversation_type" => "coaching" })
          worker.perform(convo.id)
        end
      end
    end

    context "when conversation channel is web" do
      let(:channel) { "web" }

      it "drives the conversation" do
        convo = create(:conversation, recipient: nil, channel: channel, context: { "conversation_type" => "coaching" })

        expect(MessageGenerators::Coaching).to receive(:new).with(convo).and_return(generator_instance)
        expect(generator_instance).to receive(:deliver)
        worker.perform(convo.id)
      end
    end
  end
end