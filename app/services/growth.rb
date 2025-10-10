class Growth
  def self.report
    relevant_contacts = Contact.where.not(contacted_at: nil)
    puts "Total Users Contacted: #{relevant_contacts.count}"

    unsubscribes = Contact.where(unsubscribed: true)
    puts "Total Unsubscribes: #{unsubscribes.count}"

    puts "Total Organzations: #{Organization.count}"
    puts "Total Members: #{Member.count}"
    puts "Subscribed Members: #{Member.where(subscribed: true).count}"
    puts "Subscribed Members: #{Member.where(subscribed: false).count}"

    remaining_contacts = Contact.enriched.us.where(email_queued_at: nil).where("score >= 90")
    puts "Remaining Enriched Contacts: #{remaining_contacts.count}"

    relevant_messages = Message.where(user_generated: true).where.not(content: "Give me a hint")
    base_conversations = Conversation.where(id: relevant_messages.select(:conversation_id).distinct)
    web_conversations = base_conversations.where(channel: "web")
    web_messages = Message.where(conversation_id: web_conversations.map(&:id), user_generated: true).where.not(content: "Give me a hint")
    puts "User Messages (Web): #{web_messages.count}"

    email_conversations = Conversation.where(channel: "email")
    email_messages = Message.where(conversation_id: email_conversations.pluck(:id), user_generated: true)
    puts "User Messages (Email): #{email_messages.count}"
  end
end