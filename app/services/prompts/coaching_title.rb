module Prompts
  class CoachingTitle < Prompts::Base
    def call
      parallel_batch_process { |elements| elements.present? }
    end

    def fetch_raw_response
      fetch_raw_output
    end
  end
end