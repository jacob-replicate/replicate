module Prompts
  class CoachingExplain < Prompts::Base
    def call
      parse_formatted_elements
    end
  end
end