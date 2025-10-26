module MessageGenerators
  class Article < MessageGenerators::Base
    def deliver_intro
      if @conversation.web?
        broadcast_to_web(type: "element", message: AvatarService.coach_avatar_row, user_generated: false)
        broadcast_to_web(type: "loading", user_generated: false)
        reply = Prompts::ArticleIntro.new(conversation: @conversation).call
        broadcast_to_web(type: "element", message: reply, user_generated: false)
        broadcast_to_web(type: "done")
        @conversation.messages.create!(content: "<p>#{AvatarService.coach_avatar_row}</p>#{reply}", user_generated: false)
      elsif @conversation.email?
        return
      end
    end

    def deliver_reply
      if @conversation.web?
        broadcast_to_web(type: "element", message: AvatarService.coach_avatar_row, user_generated: false)
        broadcast_to_web(type: "loading", user_generated: false)
        reply = Prompts::ArticleReply.new(conversation: @conversation).call
        broadcast_to_web(type: "element", message: reply, user_generated: false)
        broadcast_to_web(type: "done")
        @conversation.messages.create!(content: "<p>#{AvatarService.coach_avatar_row}</p>#{reply}", user_generated: false)
      elsif @conversation.email?
        return
        deliver_elements([Prompts::CoachingReply])
      end
    end
  end
end