module Prompts
  class CoachingReply < Prompts::Base
    def call
      parse_formatted_elements
    end
  end
end