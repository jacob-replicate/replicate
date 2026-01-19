module Prompts
  class GenerateQuestionCta < Prompts::Base
    def validate(raw)
      raw_json = Prompts::Base.extract_json(raw)
      failures = []

      failures << "raw_json_not_hash" unless raw_json.is_a?(Hash)
      failures << "missing_question_cta" unless raw_json["question_cta"].is_a?(Hash)

      if raw_json["question_cta"].is_a?(Hash)
        question = raw_json["question_cta"]

        unless question["title"].is_a?(String) && !question["title"].strip.empty?
          failures << "question_missing_title"
        end

        if question["title"].is_a?(String) && !question["title"].strip.end_with?("?")
          failures << "question_title_not_a_question"
        end

        unless question["options"].is_a?(Array)
          failures << "question_missing_options"
        end

        if question["options"].is_a?(Array)
          option_count = question["options"].length

          # Must have 2 or 3 options
          unless [2, 3].include?(option_count)
            failures << "question_invalid_option_count"
          end

          # If binary layout, must have exactly 2 options
          if question["layout"] == "binary" && option_count != 2
            failures << "question_binary_wrong_option_count"
          end

          question["options"].each_with_index do |opt, idx|
            unless opt.is_a?(Hash)
              failures << "question_option_#{idx}_not_hash"
              next
            end

            unless opt["title"].is_a?(String) && !opt["title"].strip.empty?
              failures << "question_option_#{idx}_missing_title"
            end

            unless opt["body"].is_a?(String) && !opt["body"].strip.empty?
              failures << "question_option_#{idx}_missing_body"
            end
          end
        end

        unless question["generation_intent"].is_a?(String) && !question["generation_intent"].strip.empty?
          failures << "question_missing_generation_intent"
        end
      end

      failures
    end

    def template_name
      "generate_question_cta"
    end
  end
end