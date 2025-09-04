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

    it "delivers email intro when conversation is email" do
      allow(conversation).to receive(:web?).and_return(false)
      allow(conversation).to receive(:email?).and_return(true)

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