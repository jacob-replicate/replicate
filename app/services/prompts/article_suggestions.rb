module Prompts
  class ArticleSuggestions < Prompts::Base
    def call
      parallel_batch_process do |raw_json|
        failures = []

        failures << "raw_json_not_hash" unless raw_json.is_a?(Hash)
        failures << "missing_title" if raw_json["title"].to_s.strip.empty?
        failures << "missing_intro_sentence" if raw_json["intro_sentence"].to_s.strip.empty?
        failures << "missing_tags" unless raw_json["tags"].is_a?(Array)
        failures << "missing_options" unless raw_json["options"].is_a?(Array)

        if raw_json["options"].is_a?(Array)
          failures << "wrong_options_size" unless raw_json["options"].size == 3

          raw_json["options"].each_with_index do |opt, idx|
            failures << "option_#{idx}_not_hash" unless opt.is_a?(Hash)
            failures << "option_#{idx}_missing_title" if opt["title"].to_s.strip.empty?
            failures << "option_#{idx}_missing_prompt_for_ai" if opt["prompt_for_ai"].to_s.strip.empty?
            failures << "option_#{idx}_title_too_long" if opt["title"].to_s.length > 100
          end
        end

        if raw_json["tags"].is_a?(Array)
          failures << "tag_count_invalid" unless raw_json["tags"].size.between?(3, 6)
          failures << "tags_not_strings" unless raw_json["tags"].all? { |t| t.is_a?(String) && t.strip.present? }
          failures << "tags_too_long" if raw_json["tags"].any? { |t| t.length > 40 }
        end

        intro = raw_json["intro_sentence"].to_s
        failures << "intro_sentence_too_long" if intro.length > 250
        failures << "intro_sentence_empty" if intro.strip.empty?

        failures << "intro_sentence_has_backticks" if intro.include?("`")
        failures << "title_has_backticks" if raw_json["title"].to_s.include?("`")
        failures << "options_have_backticks" if raw_json["options"].to_s.include?("`")

        if Rails.env.development?
          failures.each do |failure|
            Rails.logger.warn("Prompt validation failed for #{template_name}: - #{failure}")
          end
        end

        failures.empty?
      end
    end

    def fetch_raw_response
      JSON.parse(fetch_raw_output).with_indifferent_access rescue {}
    end

    def format_raw_response(raw_json)
      elements = raw_json["options"].map(&:with_indifferent_access) rescue []

      element_html = ""
      elements.shuffle.each_with_index do |option, i|
        context = Prompts::Base.build_inputs(
          conversation_type: :article,
          difficulty: @conversation.difficulty,
          title: option["title"],
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
        <div class="">
          <div class="font-medium text-lg tracking-tight mb-1">#{raw_json["title"]}</div>
          <div class="text-md mb-2">#{raw_json["intro_sentence"]}</div>
          <div class="mb-4">
            #{Array(raw_json["tags"]).map { |t| "<span class='bg-gray-600 px-2 py-1 mr-2 text-sm text-white inline-block'>#{t}</span>" }.join}
          </div>
          <div class="mb-4">
            #{element_html}
          </div>
        </div>
      HTML
    end
  end
end