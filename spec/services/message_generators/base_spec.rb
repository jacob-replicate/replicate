require "rails_helper"

RSpec.describe MessageGenerators::Base do
  let(:conversation) { create(:conversation) }
  let(:generator) { described_class.new(conversation) }

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
    it "cleans up text formatting and returns html_safe string" do
      html = "Hello s world s, and more"
      result = generator.sanitize_response(html)
      expect(result).to eq("Hellos worlds, and more")
      expect(result.html_safe?).to be(true)
    end

    it "removes duplicate closing p tags" do
      html = "<p>Hello</p></p>"
      expect(generator.sanitize_response(html)).to eq("<p>Hello</p>")
    end
  end

  describe "#deliver_elements" do
    let(:conversation) { create(:conversation, sequence_count: 0) }
    let(:generator) { MessageGenerators::Base.new(conversation) }

    it "broadcasts elements" do
      allow(ConversationChannel).to receive(:broadcast_to)

      generator.deliver_elements(["one", "two"])

      expect(ConversationChannel).to have_received(:broadcast_to).with(
        conversation,
        hash_including(type: "element", message: "one")
      )
      expect(ConversationChannel).to have_received(:broadcast_to).with(
        conversation,
        hash_including(type: "loading")
      )
      expect(ConversationChannel).to have_received(:broadcast_to).with(
        conversation,
        hash_including(type: "element", message: "two")
      )
      expect(ConversationChannel).to have_received(:broadcast_to).with(
        conversation,
        hash_including(type: "done")
      )

      expect(conversation.messages.count).to eq(1)
      expect(conversation.messages.last.content).to include("one")
      expect(conversation.messages.last.content).to include("two")
    end
  end
end