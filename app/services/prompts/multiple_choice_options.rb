module Prompts
  class MultipleChoiceOptions < Prompts::Base
    def call
      options = (JSON.parse(fetch_raw_output)["options"] || JSON.parse(fetch_raw_output)[:options]) rescue []
      options.shuffle
    end
  end
end