class PopulateConversationWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(conversation_id)
    conversation = Conversation.find(conversation_id)

    # Generate the first message for this conversation template
    # This prepopulates the intro so it's ready when users fork it
    MessageGenerators::Incident.new(conversation, nil).deliver_intro

    conversation.update!(state: "populated")
  end
end