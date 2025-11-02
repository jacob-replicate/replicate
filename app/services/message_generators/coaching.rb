module MessageGenerators
  class Coaching < MessageGenerators::Base
    def deliver_intro
      if @conversation.web?
        broadcast_to_web(type: "element", message: AvatarService.avatar_row(name: "Incident Summary"), user_generated: false)
        broadcast_to_web(type: "loading", user_generated: false)
        reply = Prompts::CoachingIntro.new(conversation: @conversation).call
        @conversation.messages.create!(content: "<p>#{AvatarService.avatar_row(name: "Incident Summary")}</p>#{reply}", user_generated: false)
        broadcast_to_web(type: "element", message: reply, user_generated: false)

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
        multiple_choice_options = 0
        generate_article_suggestions = false
        suggested_messages = @conversation.messages.user.where(suggested: true).where.not("content ILIKE ?", "%hint%")
        engaged_messages = @conversation.messages.user.where(suggested: false).where.not("content ILIKE ?", "%hint%").where.not("content ILIKE ?", "%missing here%")
        total_user_message_count = @conversation.messages.user.count
        previous_message = @conversation.messages.user.order(created_at: :desc).first&.content || ""
        turn = total_user_message_count + 1

        deliver_article_suggestions if latest_message == "Give me another hint"

        total_conversations = Conversation.where(ip_address: @conversation.ip_address)
        Rails.logger.info "Message Count: #{Message.where(user_generated: true, conversation: total_conversations).count}"
        global_messages = Message.where(user_generated: true, conversation: total_conversations).where("created_at > ?", Time.at(1762053600))
        global_message_count = global_messages.count

        if turn == 3 && suggested_messages.count == 2
          broadcast_to_web(type: "element", message: "#{AvatarService.jacob_avatar_row}<p>Don't try to win. <a href='https://gist.github.com/jacob-comer/9bba483ddd9ee3f3c379246bcba17873' class='text-blue-700 font-semibold hover:underline underline-offset-2' target='_blank'>The prompt</a> is a loop. It keeps asking hard SRE questions until you don't have a great reply.</p><p>Try answering this next one without multiple choice. How would your <span class='font-semibold'>ideal system</span> handle the pressure?</p><p class='mb-6'>Pretend leadership gave you all the time in the world to build it. Now let's poke holes in your ideas.</p>", user_generated: false)
        end

        if global_messages.where(suggested: false).count < 7 && engaged_messages.count == 4
          broadcast_to_web(type: "element", message: "#{AvatarService.jacob_avatar_row}<p class='mb-6'>Is it working? Do the questions sound like word salad now? This is where most senior engineers rage quit.</p>", user_generated: false)
        end

        broadcast_to_web(type: "element", message: AvatarService.coach_avatar_row, user_generated: false)
        broadcast_to_web(type: "loading", user_generated: false)

        custom_instructions = "- Try to return a single \"paragraph\" element. You can include \"code\" and \"line_chart\" elements too if asked, or needed to move the story along. Err on the side of a single concise paragraph most of the time. Never both 'code' and 'line_chart' in the same message. Always include at least one 'paragraph' element though."

        hint_link = nil
        reply = ""

        if latest_message == "Give me a hint"
          reply = Prompts::CoachingReply.new(conversation: @conversation, context: { custom_instructions: custom_instructions }).call
          hint_link = ANOTHER_HINT_LINK
          multiple_choice_options = 3
        elsif latest_message == "Give me another hint"
          reply = Prompts::CoachingReply.new(conversation: @conversation, context: { custom_instructions: custom_instructions }).call
          hint_link = FINAL_HINT_LINK
          multiple_choice_options = 3
        elsif latest_message == "What am I missing here?"
          reply = Prompts::CoachingExplain.new(conversation: @conversation).call
          hint_link = HINT_LINK
        elsif turn == 2
          custom_instructions = "- Try to use a \"code\" element in your reply somehow. You must end with a \"paragraph\" element though. Don't use a \"line_chart\" element unless they asked for it. Just a single \"code\" element and paragraphs. It should have logs in it, or some kind of timeline. Not actual code. Skip this instruction if it doesn't align with the story, or the engineer explicitly asked for another format/piece of data."
          reply = Prompts::CoachingReply.new(conversation: @conversation, context: { custom_instructions: custom_instructions }).call
          hint_link = HINT_LINK
          multiple_choice_options = 3
        elsif (rand(100) < 20)
          custom_instructions = "- Try to use a \"code\" element in your reply somehow. You must end with a \"paragraph\" element though. Don't use a \"line_chart\" element unless they asked for it. Just a single \"code\" element and paragraphs. It should have real code, not logs. Skip this instruction if it doesn't align with the story, or the engineer explicitly asked for another format/piece of data."
          reply = Prompts::CoachingReply.new(conversation: @conversation, context: { custom_instructions: custom_instructions }).call
          hint_link = HINT_LINK
        else
          reply = Prompts::CoachingReply.new(conversation: @conversation, context: { custom_instructions: custom_instructions }).call
          hint_link = HINT_LINK
        end

        broadcast_to_web(type: "element", message: reply, user_generated: false)
        if hint_link.present?
          broadcast_to_web(type: "element", message: hint_link, user_generated: false)
        end

        if suggested_messages.count >= 4 && engaged_messages.count < 3
          multiple_choice_options = 3
        end

        deliver_multiple_choice_options(multiple_choice_options) if multiple_choice_options.positive?

        @conversation.messages.create!(content: "<p>#{AvatarService.coach_avatar_row}</p>#{reply}", user_generated: false)
        broadcast_to_web(type: "done")
      elsif @conversation.email?
        deliver_elements([Prompts::CoachingReply])
      end
    end

    def deliver_article_suggestions
      subheader = "<span class='font-semibold tracking-tight'>Recommended Reading</span>"
      broadcast_to_web(message: subheader, type: "element", user_generated: false)
      broadcast_to_web(type: "loading", user_generated: false)

      10.times do
        response = Prompts::ArticleSuggestions.new(conversation: @conversation).call
        html = response["html"]
        if html.present?
          @conversation.messages.create!(content: "<p>#{subheader}</p>#{html}", user_generated: false)
          broadcast_to_web(message: html, type: "article_suggestions", user_generated: false)
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
  end
end