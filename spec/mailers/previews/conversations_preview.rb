# Preview all emails at http://localhost:3000/rails/mailers/conversations
class ConversationsPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/conversations/drive
  def drive
    ConversationMailer.drive
  end

end