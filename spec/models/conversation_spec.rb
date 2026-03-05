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
    it "deep-copies a template conversation for a given session, idempotently and transactionally" do
      template = create(:conversation, :template, topic: "dns")
      msg1 = create(:message, conversation: template, sequence: 1, author_name: "alice", author_avatar: "alice.png", is_system: false)
      msg2 = create(:message, conversation: template, sequence: 2, author_name: "ops-bot", author_avatar: "bot.png", is_system: true)
      create(:message_component, message: msg1, position: 1, data: { "type" => "text", "content" => "check DNS" })
      create(:message_component, message: msg1, position: 2, data: { "type" => "code", "content" => "dig example.com" })
      create(:message_component, message: msg2, position: 1, data: { "type" => "text", "content" => "resolving..." })

      forked = template.fork("session_abc")

      # linked to the template with correct attributes
      expect(forked).to be_persisted
      expect(forked.template_id).to eq(template.id)
      expect(forked.template).to be false
      expect(forked.topic).to eq("dns")
      expect(forked.session_id).to eq("session_abc")

      # duplicates messages with new IDs
      msgs = forked.messages.reorder(:sequence)
      expect(msgs.size).to eq(2)
      expect(msgs.pluck(:id) & template.messages.pluck(:id)).to be_empty

      expect(msgs[0]).to have_attributes(sequence: 1, author_name: "alice", author_avatar: "alice.png", is_system: false)
      expect(msgs[1]).to have_attributes(sequence: 2, author_name: "ops-bot", author_avatar: "bot.png", is_system: true)

      # duplicates message components
      comps = msgs[0].components.reorder(:position)
      expect(comps.size).to eq(2)
      expect(comps[0]).to have_attributes(position: 1, data: { "type" => "text", "content" => "check DNS" })
      expect(comps[1]).to have_attributes(position: 2, data: { "type" => "code", "content" => "dig example.com" })

      # idempotent for the same session_id
      second_fork = template.fork("session_abc")
      expect(second_fork.id).to eq(forked.id)
      expect(forked.messages.count).to eq(2)

      # separate fork for a different session_id
      other_fork = template.fork("session_other")
      expect(other_fork.id).not_to eq(forked.id)

      # transactional: rolls back entirely on failure
      allow_any_instance_of(MessageComponent).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
      expect {
        template.fork("session_fail") rescue nil
      }.not_to change(Conversation, :count)
    end
  end
end