module MessageGenerators
  class Article < MessageGenerators::Base
    def deliver_intro
      if @conversation.web?
        deliver_elements([AvatarService.jacob_avatar_row, Prompts::ArticleIntro])
      elsif @conversation.email?
        return
      end
    end

    def deliver_reply
      if @conversation.web?
        deliver_elements([AvatarService.jacob_avatar_row, Prompts::ArticleReply])
      elsif @conversation.email?
        return
        deliver_elements([Prompts::CoachingReply])
      end
    end
  end
end