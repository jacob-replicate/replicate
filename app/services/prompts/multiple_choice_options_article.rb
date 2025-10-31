module Prompts
  class MultipleChoiceOptionsArticle < Prompts::Base
    def call
      options = (JSON.parse(fetch_raw_output)["options"] || JSON.parse(fetch_raw_output)[:options]) rescue []
      options.shuffle.map(&:capitalize)
    end
  end
end