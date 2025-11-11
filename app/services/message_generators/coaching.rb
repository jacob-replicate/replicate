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

        title = Prompts::CoachingTitle.new(conversation: @conversation).call
        broadcast_to_web(type: "title", message: title, user_generated: false)

        deliver_multiple_choice_options(3, reply)


        broadcast_to_web(type: "done")

        @conversation.reload
        @conversation.context["title"] = title
        @conversation.save!
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


        total_conversations = Conversation.where(ip_address: @conversation.ip_address)
        global_messages = Message.where(user_generated: true, conversation: total_conversations)
        global_message_count = global_messages.count

        if turn == 8
          broadcast_to_web(type: "element", message: "#{AvatarService.jacob_avatar_row}<p class='mb-6'>I've put ~800 hours into this project since June 2025. It's just this chat UI, and a bunch of LLM orchestration I wanted an excuse to learn about. There's no paid version. At least not yet. <a href='https://forms.gle/2by63BfkbRTYQyvL9' class='text-blue-600 hover:text-blue-700 hover:underline transition font-semibold' target='_blank'>Click here</a> to stay in touch.</p>", user_generated: false)
        end

        broadcast_to_web(type: "element", message: AvatarService.coach_avatar_row, user_generated: false)
        broadcast_to_web(type: "loading", user_generated: false)

        deliver_article_suggestions if latest_message == "Give me another hint" || [5, 11].include?(turn) || (turn > 11 && rand(100) <= 10)

        hint_link = HINT_LINK
        reply = ""
        prompt = Prompts::CoachingReply

        if latest_message == "Give me a hint"
          custom_instructions = "- The user is asking for a hint. Keep it concise. Provide a single paragraph that guides them toward the next step with fewer than 300 characters. Avoid lengthy explanations or multiple paragraphs. End with a question to move the conversation along."
          hint_link = ANOTHER_HINT_LINK
          multiple_choice_options = 3
        elsif latest_message == "Give me another hint"
          custom_instructions = "- The user is asking for a hint. You must return a single \"code\" element sandwiched between concise paragraph elements that guides them toward clarity. You're not trying to stump them. You're in teaching mode, not quizzing mode now. Don't end with a question. Leave with clarity, that the engineer can follow up on in their next reply. Tee them up to feel mastery."
          hint_link = FINAL_HINT_LINK
          multiple_choice_options = 3
        elsif latest_message == "What am I missing here?" || (latest_message.length < 8 || latest_message.exclude?(" "))
          prompt = Prompts::CoachingExplain
        elsif turn == 2
          custom_instructions = "- You must return 3 elements in this order: \"paragraph\" -> \"code\" -> \"paragraph\". The code block can have have telemetry in it, or some kind of timeline, if you think that helps move the story. Otherwise use real code. The code block should have around 15 lines. No comments. Don't jump around languages. The paragraph should each have fewer than 200 characters."
          multiple_choice_options = 2
        elsif turn > 3 && rand(100) < code_cutoff
          custom_instructions = if rand(100) < 80
            "- You must return a single \"code\" element alongside your concise paragraph(s). Use real code that is relevant to the story. The snippet should have at least 15 lines, and feel like code written at a cloud-native midmarket orgnaization with ~1k employees. No startup hacks. No enterprise bloat. No comments. The code is for you to illustrate a point, not to quiz."
          else
            "- You must return a single \"code\" element sandwiched between concise paragraph elements. It should contain telemetry that is relevant to the story. The snippet should have at least 8 lines, and feel like it came from the systems at a cloud-native midmarket orgnaization with ~1k employees. No startup hacks. No enterprise bloat."
          end
        elsif turn > 3 && rand(100) < 35
          custom_instructions = "- You must return #{rand(3) + 1} \"paragraph\" elements. No additional code blocks or logs paragraphs (unless they specifically asked for them just now). Add a ton of clarity to the conversation that's lacking. Don't beat around the push. Teach, don't stress test. Use the <span class='font-semibold'>semibold Tailwind class</span> to highlight key concepts."
        else
          custom_instructions = "- Try to return a single \"paragraph\" element. No additional code blocks, logs, or paragraphs (unless they specifically asked for them just now). Concise copy that cuts deep and moves the SEV forward."
        end

        reply = prompt.new(conversation: @conversation, context: { custom_instructions: custom_instructions, cta: question_format }).call
        broadcast_to_web(type: "element", message: reply, user_generated: false)
        if hint_link.present? && turn > 1
          broadcast_to_web(type: "element", message: hint_link, user_generated: false)
        end

        if suggested_messages.count >= 4 && engaged_messages.count < 3
          multiple_choice_options = 3
        end

        deliver_multiple_choice_options(multiple_choice_options, reply) if multiple_choice_options.positive?

        @conversation.messages.create!(content: "<p>#{AvatarService.coach_avatar_row}</p>#{reply}", user_generated: false)
        broadcast_to_web(type: "done")
      elsif @conversation.email?
        deliver_elements([Prompts::CoachingReply])
      end
    end

    def deliver_article_suggestions
      return
      10.times do
        response = Prompts::ArticleSuggestions.new(conversation: @conversation).call
        html = response["html"]
        if html.present?
          @conversation.messages.create!(content: html, user_generated: false)
          broadcast_to_web(message: html, type: "article_suggestions", user_generated: false)
          return
        end
      end
    end

    def deliver_multiple_choice_options(count, reply)
      3.times do
        options = Prompts::MultipleChoiceOptions.new(conversation: @conversation, context: { max: count, most_recent_message: reply }).call

        if options.any?
          broadcast_to_web(message: options, type: "multiple_choice", user_generated: false)
          return
        end
      end
    end

    def question_format
      turn_cutoff = @conversation.difficulty == "junior" ? 4 : 6
      escalate_cutoff = @conversation.difficulty == "junior" ? 30 : 80

      escalate_cutoff = case @conversation.difficulty
        when "junior"
          25
        when "mid"
          35
        when "senior"
          75
        else
          85
      end

      if @conversation.turn < turn_cutoff || rand(100) < escalate_cutoff || @conversation.latest_user_message.to_s.include?("hint")
        escalate_prompt = "- Your reply must have a surgical question that cuts deep and declarative sentences to expose fragile reasoning, not long Wikipedia articles that teach. A question that a seasoned SRE can't help but respond to / argue with."
        escalate_prompt += "\n- Remember, this is a hypothetical infra puzzle. Your questions shouldn't be around \"What control enforces X in your system?\", but moreso \"What control SHOUD enforce X in the system\". You're not asking for details about imaginary infra. I want them to defend their mental model of how infra should be designed. You're asking how a good system should be designed (and using this story as the anchor to diagnose the engineer's blind spots)."
      else
        escalate_prompt = "- Your reply must end on a single question, in that ChatGPT style where it asks if you want to learn about X? Short Yes/no CTA that requires minimal effort to say yes to, and will teach the SRE something impactful about infra/sec that's also relevant to the story. The CTA sentence should be fewer than 80 characters. Don't make the question too long. Don't make it too specific on the returned format either. Your next reply might be a single paragraph, it might be 10. Don't box yourself in with this CTA question. Don't make it re-use the same shape you already used earlier in the convo for similar CTAs. "
      end
    end

    def code_cutoff
      case @conversation.difficulty
      when "junior"
        60
      when "mid"
        50
      when "senior"
        40
      else
        35
      end
    end
  end
end