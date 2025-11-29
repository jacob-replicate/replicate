module MessageGenerators
  class Article < MessageGenerators::Base
    def deliver_intro
      broadcast_to_web(type: "loading", user_generated: false)
      reply = Prompts::ArticleIntro.new(conversation: @conversation, cacheable: true).call
      broadcast_to_web(type: "element", message: reply, user_generated: false)
      @conversation.messages.create!(content: "#{reply}", user_generated: false)
      broadcast_to_web(type: "done")
    end

    def deliver_reply
      broadcast_to_web(type: "element", message: AvatarService.coach_avatar_row, user_generated: false)
      broadcast_to_web(type: "loading", user_generated: false)
      reply = Prompts::ArticleReply.new(conversation: @conversation).call
      broadcast_to_web(type: "element", message: reply, user_generated: false)
      @conversation.messages.create!(content: "<p>#{AvatarService.coach_avatar_row}</p>#{reply}", user_generated: false)
      broadcast_to_web(type: "done")
    end
  end
end