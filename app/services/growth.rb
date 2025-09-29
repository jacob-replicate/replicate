class Growth
  def self.report
    relevant_contacts = Contact.where.not(contacted_at: nil)
    puts "Total Users Contacted: #{relevant_contacts.count}"

    unsubscribes = Contact.where(unsubscribed: true)
    puts "Total Unsubscribes: #{unsubscribes.count}"

    puts "Total Organzations: #{Organization.count}"

    remaining_contacts = Contact.enriched.us.where(email_queued_at: nil).where("score >= 90")
    puts "Remaining Enriched Contacts: #{remaining_contacts.count}"

    web_conversations = Conversation.where(channel: "web")
    web_messages = Message.where(conversation_id: web_conversations.pluck(:id), user_generated: true)
    puts "User Messages (Web): #{web_messages.count}"

    email_conversations = Conversation.where(channel: "email")
    email_messages = Message.where(conversation_id: email_conversations.pluck(:id), user_generated: true)
    puts "User Messages (Email): #{email_messages.count}"
  end
end