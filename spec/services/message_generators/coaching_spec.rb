require "rails_helper"

RSpec.describe MessageGenerators::Coaching do
  let(:conversation) { create(:conversation) }
  let(:generator)    { described_class.new(conversation) }

  describe "#deliver_intro" do
    before do
      allow(generator).to receive(:deliver_elements)
    end

    it "delivers web intro when conversation is web" do
      allow(conversation).to receive(:web?).and_return(true)
      allow(conversation).to receive(:email?).and_return(false)

      expect(generator).to receive(:deliver_elements).with([AvatarService.coach_avatar_row, Prompts::CoachingIntro])
      generator.deliver_intro
    end

    it "delivers full email intro when first conversation for recipient" do
      allow(conversation).to receive(:web?).and_return(false)
      allow(conversation).to receive(:email?).and_return(true)

      recipient = instance_double("Recipient", conversations: double(count: 1))
      allow(conversation).to receive(:recipient).and_return(recipient)

      expected_elements = [
        "<p>Hey there,</p>",
        "<p>Taylor Jones signed you up for <a href='http://replicate.info'>Replicate</a>. There's no UI. GPT just shows up in your inbox with an infra puzzle every week. The more you think out loud, the more it can help uncover your blind spots (before production does).</p>",
        Prompts::CoachingIntro,
        instance_of(String) # unsubscribe_footer
      ]

      expect(generator).to receive(:unsubscribe_footer).with(recipient).and_return(expected_elements.last)
      expect(generator).to receive(:deliver_elements).with(expected_elements)

      generator.deliver_intro
    end

    it "delivers minimal email intro when recipient has other conversations" do
      allow(conversation).to receive(:web?).and_return(false)
      allow(conversation).to receive(:email?).and_return(true)

      recipient = instance_double("Recipient", conversations: double(count: 2))
      allow(conversation).to receive(:recipient).and_return(recipient)

      expect(generator).to receive(:deliver_elements).with([Prompts::CoachingIntro])
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

      expect(generator).to receive(:deliver_elements).with([AvatarService.coach_avatar_row, Prompts::CoachingReply])
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