require "rails_helper"

RSpec.describe Conversation, type: :model do
  describe "associations" do
    it "belongs_to template_conversation (optional)" do
      template = create(:conversation, :template)
      fork = create(:conversation, template_conversation: template)

      expect(fork.template_conversation).to eq(template)
    end

    it "has_many forked_conversations" do
      template = create(:conversation, :template)
      fork1 = create(:conversation, template_conversation: template, session_id: "s1")
      fork2 = create(:conversation, template_conversation: template, session_id: "s2")

      expect(template.forked_conversations).to contain_exactly(fork1, fork2)
    end

    it "nullifies forked_conversations on destroy" do
      template = create(:conversation, :template)
      fork = create(:conversation, template_conversation: template, session_id: "s1")

      template.destroy!
      expect(fork.reload.template_id).to be_nil
    end

    it "has_many messages and destroys them on delete" do
      convo = create(:conversation)
      msg = create(:message, conversation: convo)

      expect(convo.messages).to include(msg)

      convo.destroy!
      expect(Message.exists?(msg.id)).to be false
    end
  end

  describe ".templates" do
    it "returns only conversations where template is true" do
      template = create(:conversation, :template)
      _session_convo = create(:conversation)

      expect(Conversation.templates).to contain_exactly(template)
    end
  end

  describe "#fork" do
    let!(:template) do
      create(:conversation, :template, topic: "dns")
    end

    let!(:msg1) do
      create(:message, conversation: template, sequence: 1, author_name: "alice", author_avatar: "alice.png", is_system: false)
    end

    let!(:msg2) do
      create(:message, conversation: template, sequence: 2, author_name: "ops-bot", author_avatar: "bot.png", is_system: true)
    end

    let!(:comp1) { create(:message_component, message: msg1, position: 1, data: { "type" => "text", "content" => "check DNS" }) }
    let!(:comp2) { create(:message_component, message: msg1, position: 2, data: { "type" => "code", "content" => "dig example.com" }) }
    let!(:comp3) { create(:message_component, message: msg2, position: 1, data: { "type" => "text", "content" => "resolving..." }) }

    it "creates a new conversation linked to the template" do
      forked = template.fork("session_abc")

      expect(forked).to be_persisted
      expect(forked.template_id).to eq(template.id)
      expect(forked.template).to be false
    end

    it "copies topic to the forked conversation" do
      forked = template.fork("session_abc")

      expect(forked.topic).to eq("dns")
    end

    it "sets the session_id on the forked conversation" do
      forked = template.fork("session_abc")

      expect(forked.session_id).to eq("session_abc")
    end

    it "duplicates all messages with correct attributes" do
      forked = template.fork("session_abc")
      msgs = forked.messages.reorder(:sequence)

      expect(msgs.size).to eq(2)

      expect(msgs[0].sequence).to eq(1)
      expect(msgs[0].author_name).to eq("alice")
      expect(msgs[0].author_avatar).to eq("alice.png")
      expect(msgs[0].is_system).to be false

      expect(msgs[1].sequence).to eq(2)
      expect(msgs[1].author_name).to eq("ops-bot")
      expect(msgs[1].author_avatar).to eq("bot.png")
      expect(msgs[1].is_system).to be true
    end

    it "duplicates all message components with correct attributes" do
      forked = template.fork("session_abc")
      first_msg = forked.messages.reorder(:sequence).first
      comps = first_msg.components.reorder(:position)

      expect(comps.size).to eq(2)

      expect(comps[0].position).to eq(1)
      expect(comps[0].data).to eq({ "type" => "text", "content" => "check DNS" })

      expect(comps[1].position).to eq(2)
      expect(comps[1].data).to eq({ "type" => "code", "content" => "dig example.com" })
    end

    it "creates new record IDs (not reusing template message IDs)" do
      forked = template.fork("session_abc")
      forked_msg_ids = forked.messages.pluck(:id)
      template_msg_ids = template.messages.pluck(:id)

      expect(forked_msg_ids & template_msg_ids).to be_empty
    end

    it "returns the existing fork for the same session_id (idempotent)" do
      first_fork = template.fork("session_abc")
      second_fork = template.fork("session_abc")

      expect(second_fork.id).to eq(first_fork.id)
    end

    it "does not create duplicate messages on repeated calls" do
      template.fork("session_abc")
      template.fork("session_abc")

      forked = template.forked_conversations.find_by(session_id: "session_abc")
      expect(forked.messages.count).to eq(2)
    end

    it "creates separate forks for different session_ids" do
      fork1 = template.fork("session_1")
      fork2 = template.fork("session_2")

      expect(fork1.id).not_to eq(fork2.id)
      expect(fork1.messages.pluck(:id) & fork2.messages.pluck(:id)).to be_empty
    end

    it "wraps creation in a transaction (all or nothing)" do
      allow_any_instance_of(MessageComponent).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

      expect {
        template.fork("session_abc") rescue nil
      }.not_to change(Conversation, :count)
    end
  end
end