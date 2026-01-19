module Prompts
  class MultipleChoiceOptions < Prompts::Base
    def parse_response(raw)
      options = Prompts::Base.extract_json(raw)["options"] || []
      options.map { |x| x.gsub("*", "") }
    end

    def validate(raw)
      options = Prompts::Base.extract_json(raw)["options"] || []
      failures = []
      failures << "wrong_count" unless [2, 3].include?(options.size)
      options.each_with_index do |opt, idx|
        failures << "option_#{idx}_too_long" if SanitizeAiContent.call(opt).length > 100
        failures << "option_#{idx}_has_asterisks" if opt.include?("*")
        failures << "option_#{idx}_has_backticks" if opt.include?("`")
      end
      failures
    end
  end
end