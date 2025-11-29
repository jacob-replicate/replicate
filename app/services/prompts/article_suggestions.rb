module Prompts
  class ArticleSuggestions < Prompts::Base
    def call
      parallel_batch_process do |raw_json|
        failures = []

        failures << "raw_json_not_hash" unless raw_json.is_a?(Hash)
        failures << "missing_title" if raw_json["title"].to_s.strip.empty?
        failures << "missing_intro_sentence" if raw_json["intro_sentence"].to_s.strip.empty?
        failures << "missing_posts" unless raw_json["posts"].is_a?(Array)

        if raw_json["posts"].is_a?(Array)
          failures << "wrong_posts" unless raw_json["posts"].size == 4

          raw_json["posts"].each_with_index do |opt, idx|
            failures << "option_#{idx}_not_hash" unless opt.is_a?(Hash)
            failures << "option_#{idx}_missing_title" if opt["blog_title"].to_s.strip.empty?
            failures << "option_#{idx}_missing_prompt_for_ai" if opt["prompt_for_ai"].to_s.strip.empty?
            failures << "option_#{idx}_title_too_long" if opt["title"].to_s.length > 60
          end
        end

        title = raw_json["category_title"].to_s
        title_without_acronyms = title.split.reject { |word| word.upcase == word }.join(" ").squish
        failures << "title_too_long" if title.length > 80
        failures << "title_wrong_casing" if title_without_acronyms != title_without_acronyms.capitalize

        intro = raw_json["intro_sentence"].to_s
        failures << "intro_sentence_too_long" if intro.length > 120
        failures << "intro_sentence_empty" if intro.strip.empty?

        failures << "intro_sentence_has_backticks" if intro.include?("`")
        failures << "title_has_backticks" if raw_json["category_title"].to_s.include?("`")
        failures << "posts_have_backticks" if raw_json["posts"].to_json.include?("`")

        if Rails.env.development?
          failures.each do |failure|
            Rails.logger.warn("Prompt validation failed for #{template_name}: - #{failure} - #{raw_json.inspect}")
          end

          if failures.any?
            Rails.logger.info("END VAIDATION--------------")
          end
        end

        failures.empty?
      end
    end

    def fetch_raw_response
      JSON.parse(fetch_raw_output).with_indifferent_access
    end

    def format_raw_response(raw_json)
      elements = raw_json["posts"].map(&:with_indifferent_access) rescue []

      element_html = ""
      elements.shuffle.each_with_index do |option, i|
        context = Prompts::Base.build_inputs(
          conversation_type: :article,
          difficulty: @conversation.difficulty,
          title: option["blog_title"],
          prompt_for_ai: option["prompt_for_ai"],
        )

        conversation = Conversation.create!(channel: "web", context: context)
        conversation_id = conversation.id

        CacheLlmResponseWorker.perform_async(context, "ArticleIntro")

        element_html << <<~HTML
          <a
            href="/conversations/#{conversation_id}"
            target="_blank"
            rel="noopener noreferrer"
            class="text-[16px] py-2 block #{i < (elements.size - 1) ? 'border-b border-gray-200' : ''} cursor-pointer transition no-underline"
          >
            <div href="/conversations/#{conversation_id}" target="_blank" class="text-indigo-600 text-[15px] hover:underline hover:underline-offset-4">
              #{ERB::Util.html_escape(option["title"])}
            </div>
          </a>
        HTML
      end

      <<~HTML
        <div class="mt-10">
          <div class="flex flex-row items-center">
            <div class="lg:basis-[60%]">
              <div class="font-medium text-lg tracking-tight mb-1">#{raw_json["category_title"]}</div>
              <div class="text-md mb-1">#{raw_json["intro_sentence"]}</div>
              <div>
                #{element_html}
              </div>
            </div>
            <div class="hidden lg:block lg:basis-[40%] text-center" style="padding: 0 30px">
              <img src="/learning-0.jpg" class="w-full" />
            </div>
          </div>
        </div>
      HTML
    end
  end
end