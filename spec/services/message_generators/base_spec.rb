require "rails_helper"

RSpec.describe MessageGenerators::Base do
  let(:conversation) { create(:conversation) }
  let(:generator)    { described_class.new(conversation) }

  describe "#deliver" do
    before do
      allow(conversation).to receive(:latest_author).and_return(latest_author)
      allow(conversation).to receive(:latest_user_message).and_return(latest_user_message)
      allow(generator).to receive(:deliver_intro)
      allow(generator).to receive(:deliver_reply)
    end

    context "when latest author is assistant" do
      let(:latest_author) { :assistant }
      let(:latest_user_message) { nil }

      it "does nothing" do
        generator.deliver
        expect(generator).not_to have_received(:deliver_intro)
        expect(generator).not_to have_received(:deliver_reply)
      end
    end

    context "when latest user message is present" do
      let(:latest_author) { :user }
      let(:latest_user_message) { "I'm confused" }

      it "calls deliver_reply" do
        generator.deliver
        expect(generator).to have_received(:deliver_reply)
      end
    end

    context "when latest user message is blank" do
      let(:latest_author) { :user }
      let(:latest_user_message) { nil }

      it "calls deliver_intro" do
        generator.deliver
        expect(generator).to have_received(:deliver_intro)
      end
    end
  end

  describe "#deliver_intro / #deliver_reply" do
    it "raises NotImplementedError for deliver_intro" do
      expect { generator.deliver_intro }.to raise_error(NotImplementedError)
    end

    it "raises NotImplementedError for deliver_reply" do
      expect { generator.deliver_reply }.to raise_error(NotImplementedError)
    end
  end

  describe "#sanitize_response" do
    it "removes <pre> tags" do
      html = "<pre>Hello</pre>"
      expect(generator.sanitize_response(html)).to eq("Hello")
    end
  end

  describe "#deliver_elements" do
    let(:conversation) { create(:conversation, channel: "web") }
    let(:generator) { MessageGenerators::Base.new(conversation) }

    it "broadcasts elements to web" do
      initial_seq = conversation.next_message_sequence

      expect(ConversationChannel).to receive(:broadcast_to).with(conversation, { type: "element", sequence: initial_seq, user_generated: false, message: "one" }).ordered
      expect(ConversationChannel).to receive(:broadcast_to).with(conversation, { type: "loading", sequence: initial_seq + 1, user_generated: false }).ordered
      expect(ConversationChannel).to receive(:broadcast_to).with(conversation, { type: "element", sequence: initial_seq + 2, user_generated: false, message: "two" }).ordered
      expect(ConversationChannel).to receive(:broadcast_to).with(conversation, { type: "done", sequence: initial_seq + 3, user_generated: false }).ordered

      expect(ConversationChannel).to receive(:broadcast_to).with(conversation, { type: "element", sequence: initial_seq + 4, user_generated: false, message: "three" }).ordered
      expect(ConversationChannel).to receive(:broadcast_to).with(conversation, { type: "loading", sequence: initial_seq + 5, user_generated: false }).ordered
      expect(ConversationChannel).to receive(:broadcast_to).with(conversation, { type: "element", sequence: initial_seq + 6, user_generated: false, message: "four" }).ordered
      expect(ConversationChannel).to receive(:broadcast_to).with(conversation, { type: "done", sequence: initial_seq + 7, user_generated: false }).ordered

      expect(ConversationChannel).to receive(:broadcast_to).with(conversation, { type: "element", sequence: initial_seq + 8, user_generated: false, message: "five" }).ordered
      expect(ConversationChannel).to receive(:broadcast_to).with(conversation, { type: "done", sequence: initial_seq + 9, user_generated: false }).ordered

      generator.deliver_elements(["<pre>one", "</pre> two"])
      generator.deliver_elements(["three", "four"])
      generator.deliver_elements(["five"])

      expect(conversation.messages.pluck(:content)).to match_array(["one\ntwo", "three\nfour", "five"])
    end

    it "delivers elements to email" do
      conversation = create(:conversation, channel: "email", recipient: create(:member))
      generator = MessageGenerators::Base.new(conversation)

      mailer_double = double("Mailer", deliver_now: true)
      expect(ConversationsMailer).to receive(:drive).with(conversation).and_return(mailer_double)
      expect(mailer_double).to receive(:deliver_now)

      expect(Prompts::CoachingReply).to receive(:new).with(conversation: conversation).and_return(double(call: "GPT reply"))
      generator.deliver_elements([Prompts::CoachingReply, "hardcoded signature"])

      message = conversation.messages.last
      expect(message.content).to eq("<p>GPT reply</p>\nhardcoded signature")
    end
  end
end