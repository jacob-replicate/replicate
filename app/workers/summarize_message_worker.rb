class SummarizeMessageWorker
  include Sidekiq::Worker

  def perform(message_id)
    message = Message.find_by(id: message_id)
    return if message.blank?

    # TODO: Eventually move to S3, instead of storing huge blocks of text in Postgres
    message.update(
      summary: Prompt.new(:summarize, input: { message: message.content }).execute,
      state: :summarized
    )
  end
end