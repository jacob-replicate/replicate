module Prompts
  class MultipleChoiceOptionsArticle < Prompts::Base
    def parse_response(raw)
      options = Prompts::Base.extract_json(raw)["options"] || []
      options.shuffle
    end

    def validate(raw)
      options = Prompts::Base.extract_json(raw)["options"] || []
      options.size == 3 ? [] : ["wrong_count"]
    end
  end
end