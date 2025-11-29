module Prompts
  class MultipleChoiceOptionsArticle < Prompts::Base
    def call
      parallel_batch_process(format: false) do |elements|
        elements.size == 3
      end
    end

    def fetch_raw_response
      options = (JSON.parse(fetch_raw_output)["options"] || JSON.parse(fetch_raw_output)[:options]) rescue []
      options.shuffle
    end
  end
end