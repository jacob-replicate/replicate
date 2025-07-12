class SendMessageWorker
  include Sidekiq::Worker

  def perform(conversation_id, message_body = nil)
    conversation = Conversation.find_by(id: conversation_id)
    return if conversation.blank?

    message_template = "MessageGenerators::#{context[:conversation_type]}".constantize.new(conversation)
    message_template.deliver
  end
end