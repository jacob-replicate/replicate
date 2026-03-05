require "rails_helper"

RSpec.describe "Api::Conversations", type: :request do
  before do
    allow_any_instance_of(ApplicationController).to receive(:skip_malicious_users).and_return(nil)
    allow_any_instance_of(ApplicationController).to receive(:session_identifier).and_return("test-session")
  end

  describe "GET /api/conversations" do
    it "returns one template per topic, formatted as JSON" do
      old_dns = create(:conversation, :template, topic: "dns", created_at: 1.day.ago)
      new_dns = create(:conversation, :template, topic: "dns", created_at: Time.current)
      ssl     = create(:conversation, :template, topic: "ssl")
      _fork   = create(:conversation, topic: "dns", session_id: "s1")

      get "/api/conversations"

      expect(response).to have_http_status(:ok)
      topics = response.parsed_body.map { |c| c["topic"] }
      expect(topics).to contain_exactly("dns", "ssl")

      dns_entry = response.parsed_body.find { |c| c["topic"] == "dns" }
      expect(dns_entry.keys).to include("id", "topic", "template", "template_id", "created_at", "updated_at")
      expect(dns_entry).not_to have_key("messages")
    end
  end

  describe "GET /api/conversations/:id" do
    it "forks the template for the session and returns messages with components" do
      template = create(:conversation, :template, topic: "dns")
      msg = create(:message, conversation: template, sequence: 1, author_name: "alice", author_avatar: "a.png", is_system: false)
      create(:message_component, message: msg, position: 1, data: { "type" => "text", "content" => "hello" })

      get "/api/conversations/#{template.id}"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body

      # it's a fork, not the template itself
      expect(body["id"]).not_to eq(template.id)
      expect(body["template"]).to be false
      expect(body["template_id"]).to eq(template.id)
      expect(body["topic"]).to eq("dns")

      # includes messages with components
      expect(body["messages"].size).to eq(1)
      m = body["messages"].first
      expect(m).to include("sequence" => 1, "author_name" => "alice", "is_system" => false)
      expect(m["components"]).to eq([{ "type" => "text", "content" => "hello" }])

      # idempotent within the same session
      get "/api/conversations/#{template.id}"
      expect(response.parsed_body["id"]).to eq(body["id"])
    end
  end

  describe "PATCH /api/conversations/:id" do
    it "updates last_read_message_id on a forked conversation belonging to the current session" do
      template = create(:conversation, :template, topic: "dns")
      create(:message, conversation: template, sequence: 1)

      # fork via show so the conversation is tied to our session
      get "/api/conversations/#{template.id}"
      fork_id = response.parsed_body["id"]
      msg_id = response.parsed_body["messages"].first["id"]

      patch "/api/conversations/#{fork_id}", params: { last_read_message_id: msg_id }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["last_read_message_id"]).to eq(msg_id)

      # cannot update a conversation from a different session
      other_fork = create(:conversation, topic: "dns", session_id: "someone_else")
      patch "/api/conversations/#{other_fork.id}", params: { last_read_message_id: 1 }
      expect(response).to have_http_status(:not_found)
    end
  end
end