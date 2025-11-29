module Prompts
  class MultipleChoiceOptions < Prompts::Base
    def call
      parallel_batch_process(format: false) do |elements|
        [2,3].include?(elements.size) && elements.all? { |opt| SanitizeAiContent.call(opt).length <= 100 && opt.exclude?("*") && opt.exclude?("`") }
      end
    end

    def fetch_raw_response
      options = (JSON.parse(fetch_raw_output)["options"] || JSON.parse(fetch_raw_output)[:options]) rescue []
      options.map { |x| x.gsub("*", "") }
    end
  end
end