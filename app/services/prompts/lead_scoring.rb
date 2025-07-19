module Prompts
  class LeadScoring < Prompts::Base
    def call
      JSON.parse(fetch_valid_response)
    end
  end
end