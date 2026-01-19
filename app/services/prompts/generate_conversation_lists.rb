module Prompts
  class GenerateConversationLists < Prompts::Base
    def validate(raw)
      raw_json = Prompts::Base.extract_json(raw)
      failures = []

      failures << "raw_json_not_hash" unless raw_json.is_a?(Hash)
      failures << "missing_categories" unless raw_json["categories"].is_a?(Array)

      if raw_json["categories"].is_a?(Array)
        failures << "too_few_categories" if raw_json["categories"].length < 4
        failures << "too_many_categories" if raw_json["categories"].length > 8

        raw_json["categories"].each_with_index do |category, idx|
          failures << "category_#{idx}_missing_name" unless category["name"].is_a?(String) && !category["name"].strip.empty?
          failures << "category_#{idx}_missing_questions" unless category["questions"].is_a?(Array)

          if category["questions"].is_a?(Array)
            failures << "category_#{idx}_too_few_questions" if category["questions"].length < 2
            failures << "category_#{idx}_too_many_questions" if category["questions"].length > 6

            category["questions"].each_with_index do |question, q_idx|
              unless question.is_a?(String) && !question.strip.empty?
                failures << "category_#{idx}_question_#{q_idx}_empty"
              end

              unless question.to_s.strip.end_with?("?")
                failures << "category_#{idx}_question_#{q_idx}_missing_question_mark"
              end

              if question.is_a?(String) && question.length > 100
                failures << "category_#{idx}_question_#{q_idx}_too_long"
              end
            end
          end
        end
      end

      failures
    end
  end
end