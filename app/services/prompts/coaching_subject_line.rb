module Prompts
  class CoachingSubjectLine < Prompts::Base
    def call
      fetch_valid_response.gsub("\"", "")
    end
  end
end