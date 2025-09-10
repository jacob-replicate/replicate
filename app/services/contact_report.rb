class ContactReport
  def self.call
    score_counts = Contact.group(:score).count
    total = Contact.count
    scored = Contact.where.not(score_reason: nil).count
    unscored = total - scored

    puts "Total contacts: #{total}"
    puts "Scored: #{scored}"
    puts "Unscored: #{unscored}"
    puts

    sorted_scores = score_counts.keys.compact.sort.reverse

    sorted_scores.each do |score|
      contacts = Contact.where(score: score)
      conversation_count = contacts.contacted.count
      puts "Score #{score}: #{contacts.count} contacts, #{conversation_count} conversations"
    end
  end
end