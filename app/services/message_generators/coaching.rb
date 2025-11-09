module MessageGenerators
  class Coaching < MessageGenerators::Base
    def deliver_intro
      if @conversation.web?
        broadcast_to_web(type: "element", message: AvatarService.avatar_row(name: "Incident Summary"), user_generated: false)
        broadcast_to_web(type: "loading", user_generated: false)

        avatar = "<p>#{AvatarService.avatar_row(name: "Incident Summary")}</p>"

        reply = if @conversation.referring_conversation.present?
          @conversation.referring_conversation.messages.where(user_generated: false).order(created_at: :asc).first&.content&.gsub(avatar, "")
        else
          Prompts::CoachingIntro.new(conversation: @conversation).call
        end

        @conversation.messages.create!(content: "#{avatar}#{reply}", user_generated: false)
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
        suggested_messages = @conversation.messages.user.where(suggested: true).where.not("content ILIKE ?", "%hint%")
        engaged_messages = @conversation.messages.user.where(suggested: false).where.not("content ILIKE ?", "%hint%").where.not("content ILIKE ?", "%missing here%")
        total_user_message_count = @conversation.messages.user.count
        previous_message = @conversation.messages.user.order(created_at: :desc).first&.content || ""
        turn = total_user_message_count + 1

        deliver_article_suggestions if latest_message == "Give me another hint" || [5, 11].include?(turn) || (turn > 11 && rand(100) < 15)

        total_conversations = Conversation.where(ip_address: @conversation.ip_address)
        global_messages = Message.where(user_generated: true, conversation: total_conversations).where("created_at > ?", Time.at(1762053600))
        global_message_count = global_messages.count

        if turn == 3
          broadcast_to_web(type: "element", message: "#{AvatarService.jacob_avatar_row}<p>Don't try to win. <a href='https://gist.github.com/jacob-comer/9bba483ddd9ee3f3c379246bcba17873' class='text-blue-700 font-semibold hover:underline underline-offset-2' target='_blank'>The prompt</a> is a loop. It keeps asking hard SRE questions until you don't have a great reply.</p><p>Try answering this next one without multiple choice. How would your <span class='font-semibold'>ideal system</span> handle the pressure?</p><p class='mb-6'>Let GPT poke holes in your best ideas. It's not perfect, but I think it will be a lot sharper than you expect.</p>", user_generated: false)
          multiple_choice_options = 0
        end

        if turn == 10
          broadcast_to_web(type: "element", message: "#{AvatarService.jacob_avatar_row}<p class='mb-6'>I've put ~800 hours into this project since June 2025. It's just a chat window, and a bunch of LLM orchestration. I don't want to run a SaaS company. I just want an infra/sec coaching tool that doesn't suck. It's getting there.</p>", user_generated: false)
        end

        if turn == 15
          broadcast_to_web(type: "element", message: "#{AvatarService.jacob_avatar_row}<p class='mb-6'>It might be time for a <a href='/sev' class='text-blue-700 font-semibold hover:underline hover:underline-offset-2' target='_blank'>new SEV-1</a>. GPT veers off into meta distributed systems theory around this point.</p>", user_generated: false)
        end

        broadcast_to_web(type: "element", message: AvatarService.coach_avatar_row, user_generated: false)
        broadcast_to_web(type: "loading", user_generated: false)

        hint_link = nil
        reply = ""

        if latest_message == "Give me a hint"
          custom_instructions = "- The user is asking for a hint. Keep it concise. Provide a single paragraph that guides them toward the next step with fewer than 300 characters. Avoid lengthy explanations or multiple paragraphs."
          reply = Prompts::CoachingReply.new(conversation: @conversation, context: { custom_instructions: custom_instructions }).call
          hint_link = ANOTHER_HINT_LINK
          multiple_choice_options = 3
        elsif latest_message == "Give me another hint"
          custom_instructions = "- The user is asking for a hint. Provide 3 paragraphs with less than 250 characters each that guides them toward clarity. You're not trying to stump them. You're in teaching mode, not quizzing mode now."
          reply = Prompts::CoachingReply.new(conversation: @conversation, context: { custom_instructions: custom_instructions }).call
          hint_link = FINAL_HINT_LINK
          multiple_choice_options = 3
        elsif latest_message == "What am I missing here?"
          reply = Prompts::CoachingExplain.new(conversation: @conversation).call
          hint_link = HINT_LINK
        elsif turn == 2
          custom_instructions = "- You must return 3 elements in this order: \"paragraph\" -> \"code\" -> \"paragraph\". The code block should have telemetry in it, or some kind of timeline. Not actual code. The paragraphs should each have fewer than 200 characters."
          reply = Prompts::CoachingReply.new(conversation: @conversation, context: { custom_instructions: custom_instructions }).call
          hint_link = HINT_LINK
          multiple_choice_options = 2
        elsif turn > 3 && rand(100) < 40
          custom_instructions = if rand(100) < 80
            "- You must return a single \"code\" element alongside your concise paragraph(s). The code should be relevant to the story. Use real code, not telemetry."
          else
            "- You must return a single \"code\" element alongside your concise paragraph(s). The code should be relevant to the story. Use real code, not telemetry."
          end

          reply = Prompts::CoachingReply.new(conversation: @conversation, context: { custom_instructions: custom_instructions }).call
          hint_link = HINT_LINK
        elsif turn > 3 && rand(100) < 35
          custom_instructions = "- You must return #{rand(4) + 1} \"paragraph\" elements. No additional code blocks or logs paragraphs (unless they specifically asked for them just now). Don't ask questions in this one. Just add a ton of clarity to the conversation that's lacking. Don't beat around the push. Teach, don't stress test. Use the <span class='font-semibold'>semibold Tailwind class</span> to highlight key concepts."
          reply = Prompts::CoachingReply.new(conversation: @conversation, context: { custom_instructions: custom_instructions }).call
          hint_link = HINT_LINK
        else
          custom_instructions = "- Try to return a single \"paragraph\" element. No additional code blocks, logs, or paragraphs (unless they specifically asked for them just now). Concise copy that cuts deep and moves the SEV forward."
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