module Prompts
  class MultipleChoiceOptions < Prompts::Base
    def call
      parallel_batch_process(format: false) do |elements|
        Rails.logger.info("MultipleChoiceOptions - elements: #{elements.inspect}")
        [2,3].include?(elements.size) && elements.all? { |opt| SanitizeAiContent.call(opt).length <= 100 && opt.exclude?("*") }
      end
    end

    def fetch_elements
      options = (JSON.parse(fetch_raw_output)["options"] || JSON.parse(fetch_raw_output)[:options]) rescue []
      options.shuffle.map { |x| x.gsub("*", "") }
    end
  end
end