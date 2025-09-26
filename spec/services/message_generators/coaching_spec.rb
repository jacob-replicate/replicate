require "rails_helper"

RSpec.describe MessageGenerators::Coaching do
  let!(:organization) { create(:organization) }
  let!(:owner)        { create(:member, role: "owner", organization: organization, name: "Jacob Comer") }
  let!(:conversation) { create(:conversation, recipient: create(:member, role: "engineer", organization: organization)) }
  let!(:recipient) { conversation.recipient }
  let!(:generator)    { described_class.new(conversation) }

  describe "#deliver_intro" do
    before do
      allow(generator).to receive(:deliver_elements)
    end

    it "delivers web intro when conversation is web" do
      allow(conversation).to receive(:web?).and_return(true)
      allow(conversation).to receive(:email?).and_return(false)

      expect(generator).to receive(:deliver_elements).with([AvatarService.coach_avatar_row, Prompts::CoachingIntro, HINT_INK])
      generator.deliver_intro
    end

    it "delivers full email intro when first conversation for recipient" do
      allow(conversation).to receive(:web?).and_return(false)
      allow(conversation).to receive(:email?).and_return(true)

      expected_elements = [
        "Hey there,",
        "<p>#{owner.name} added you to their <a href='https://replicate.info'>replicate.info</a> team. No UI. GPT just shows up in your inbox with an infra puzzle every week. The more you think out loud, the more it can help uncover your blind spots (before production does).</p>",
        Prompts::CoachingIntro,
        generator.send(:unsubscribe_footer, recipient)
      ]

      expect(generator).to receive(:deliver_elements).with(expected_elements)

      generator.deliver_intro
    end

    it "delivers full email intro when first conversation for recipient (even without owner)" do
      allow(conversation).to receive(:web?).and_return(false)
      allow(conversation).to receive(:email?).and_return(true)
      owner.destroy

      expected_elements = [
        "Hey there,",
        "<p>One of your teammates added you to their <a href='https://replicate.info'>replicate.info</a> team. No UI. GPT just shows up in your inbox with an infra puzzle every week. The more you think out loud, the more it can help uncover your blind spots (before production does).</p>",
        Prompts::CoachingIntro,
        generator.send(:unsubscribe_footer, recipient)
      ]

      expect(generator).to receive(:deliver_elements).with(expected_elements)

      generator.deliver_intro
    end

    it "delivers minimal email intro when recipient has other conversations" do
      allow(conversation).to receive(:web?).and_return(false)
      allow(conversation).to receive(:email?).and_return(true)

      recipient = instance_double("Recipient", engineer?: true, id: 1234, conversations: double(count: 2))
      allow(conversation).to receive(:recipient).and_return(recipient)

      expect(generator).to receive(:deliver_elements).with(["Hey there,", Prompts::CoachingIntro, generator.send(:unsubscribe_footer, recipient)])
      generator.deliver_intro
    end
  end

  describe "#deliver_reply" do
    before do
      allow(generator).to receive(:deliver_elements)
    end

    it "delivers web reply when conversation is web" do
      allow(conversation).to receive(:web?).and_return(true)
      allow(conversation).to receive(:email?).and_return(false)

      expect(generator).to receive(:deliver_elements).with([AvatarService.coach_avatar_row, Prompts::CoachingReply, HINT_LINK])
      generator.deliver_reply
    end

    it "delivers email reply when conversation is email" do
      allow(conversation).to receive(:web?).and_return(false)
      allow(conversation).to receive(:email?).and_return(true)

      expect(generator).to receive(:deliver_elements).with([Prompts::CoachingReply])
      generator.deliver_reply
    end
  end
end