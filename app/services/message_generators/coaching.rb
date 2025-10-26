module MessageGenerators
  class Coaching < MessageGenerators::Base
    def deliver_intro
      if @conversation.web?
        deliver_elements([AvatarService.coach_avatar_row, Prompts::CoachingIntro], false, true)
        deliver_multiple_choice_options(3)
        broadcast_to_web(type: "done")
      elsif @conversation.email?
        elements = ["Hey there,"]

        recipient = @conversation.recipient
        if recipient&.engineer? && recipient.conversations.count == 1
          owner_name = @conversation.recipient.organization.members.find_by(role: "owner")&.name || "One of your teammates"
          elements << "<p>#{owner_name} added you to their <a href='https://replicate.info'>replicate.info</a> team. No UI. GPT just shows up in your inbox with an infra puzzle every week. The more you think out loud, the more it can help uncover your blind spots (before production does).</p>"
        end

        elements << Prompts::CoachingIntro
        elements << unsubscribe_footer(@conversation.recipient)

        deliver_elements(elements)
      end
    end

    def deliver_reply
      if @conversation.web?
        latest_message = @conversation.latest_user_message.content
        elements = [AvatarService.coach_avatar_row]
        multiple_choice_options = 0
        generate_article_suggestions = false
        suggested_messages = @conversation.messages.user.where(suggested: true).where.not("content ILIKE ?", "%hint%")
        engaged_messages = @conversation.messages.user.where(suggested: false).where.not("content ILIKE ?", "%hint%")
        total_user_message_count = @conversation.messages.user.count

        if total_user_message_count == 3 || (total_user_message_count % 6) == 0 || latest_message == "What am I missing here?"
          generate_article_suggestions = true unless latest_message.include?("hint")
        end

        deliver_article_suggestions if generate_article_suggestions

        broadcast_to_web(type: "element", message: AvatarService.coach_avatar_row, user_generated: false)
        broadcast_to_web(type: "loading", user_generated: false)

        reply = "<p>AvatarService.coach_avatar_row</p>"
        hint_link = nil
        if engaged_messages.blank? && suggested_messages.count < 3
          reply = Prompts::CoachingReply.new(conversation: @conversation).call
          multiple_choice_options = 3
        elsif latest_message == "Give me a hint"
          reply = Prompts::CoachingReply.new(conversation: @conversation).call
          hint_link = ANOTHER_HINT_LINK
        elsif latest_message == "Give me another hint"
          reply = Prompts::CoachingReply.new(conversation: @conversation).call
          hint_link = FINAL_HINT_LINK
          multiple_choice_options = 3
        elsif latest_message == "What am I missing here?"
          reply = Prompts::CoachingExplain.new(conversation: @conversation).call
          hint_link = HINT_LINK
        else
          reply = Prompts::CoachingReply.new(conversation: @conversation).call
          hint_link = HINT_LINK
        end

        broadcast_to_web(type: "element", message: reply, user_generated: false)
        if hint_link.present?
          broadcast_to_web(type: "element", message: hint_link, user_generated: false)
        end

        deliver_multiple_choice_options(multiple_choice_options) if multiple_choice_options.positive?

        @conversation.messages.create!(content: reply, user_generated: false)
        broadcast_to_web(type: "done")
      elsif @conversation.email?
        deliver_elements([Prompts::CoachingReply])
      end
    end

    def deliver_article_suggestions
      broadcast_to_web(message: AvatarService.jacob_avatar_row, type: "element", user_generated: false)
      broadcast_to_web(type: "loading", user_generated: false)

      3.times do
        response = Prompts::ArticleSuggestions.new(conversation: @conversation).call
        options = response["options"]
        intro_sentence = response["intro_sentence"]

        if options.any?
          broadcast_to_web(message: "<p>#{intro_sentence}</p>", type: "element", user_generated: false)
          broadcast_to_web(message: options, type: "article_suggestions", user_generated: false)
          return
        end
      end
    end

    def deliver_multiple_choice_options(count)
      3.times do
        options = Prompts::MultipleChoiceOptions.new(conversation: @conversation, context: { max: count }).call

        if options.any?
          broadcast_to_web(message: options, type: "multiple_choice", user_generated: false)
          return
        end
      end
    end

    def article_suggest_intro_sentences
      [
        "Interesting direction. These might help connect the dots a bit further.",
        "You're on the right track. Here are a few writeups that go a bit deeper.",
        "This reminded me of a few good reads. Might help sharpen the boundary you're exploring.",
        "Good instincts. Here's some reading that pushes the idea further if you're in the mood.",
        "You’re circling something important. Do these links spark any ideas?",

        "If you're hitting a blind spot, these might help unblock it. No rush.",

        "This echoes some lessons we’ve seen before. Might be worth skimming:",
        "Strong read. Want to see how others handled something similar?",
        "Good catch. These notes might back up the mental model you're sketching.",
        "You’re asking the right questions. Here's some backup thinking that digs deeper.",
        "Sharp. Here are a few more nudges in that same direction.",
        "Noticed you’re probing at a tough edge case. These might help sharpen the intuition.",
        "You’re pushing into real systems territory. This might help add language to what you're seeing.",
        "These might give you a clearer lens on the tradeoff you're wrestling with.",
        "Seen others get burned here — this writeup captures it well.",
        "You're not wrong — here's how others have tried to thread that same needle.",
        "Some context that might help de-risk your next move.",
        "You’re not far off. These go a bit deeper down that rabbit hole.",
        "The questions you're asking deserve better answers. These helped me.",
        "If this feels murky, you’re not alone. These helped clarify it for others.",
        "This one gets weird fast. Here are some breadcrumbs to stay grounded.",
        "You're brushing up against a blind spot most folks don’t notice. These might help.",
        "If that part felt shaky, these reads usually land well for folks at your level."
      ]
    end
  end
end