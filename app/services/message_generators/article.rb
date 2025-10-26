module MessageGenerators
  class Article < MessageGenerators::Base
    def deliver_intro
      if @conversation.web?
        deliver_elements([AvatarService.jacob_avatar_row], false, true)
        broadcast_to_web(type: "loading", user_generated: false)
        broadcast_to_web(type: "element", message: Prompts::ArticleIntro.new(conversation: @conversation).call, user_generated: false)
        broadcast_to_web(type: "done")
      elsif @conversation.email?
        return
      end
    end

    def deliver_reply
      if @conversation.web?
        deliver_elements([AvatarService.jacob_avatar_row], false, true)
        broadcast_to_web(type: "loading", user_generated: false)
        broadcast_to_web(type: "element", message: Prompts::ArticleReply.new(conversation: @conversation).call, user_generated: false)
        broadcast_to_web(type: "done")
      elsif @conversation.email?
        return
        deliver_elements([Prompts::CoachingReply])
      end
    end
  end
end