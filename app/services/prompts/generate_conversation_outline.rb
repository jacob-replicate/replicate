module Prompts
  class GenerateConversationOutine < Prompts::Base
    def call
      parallel_batch_process(format: false) do |outline|
        true
      end
    end

    def fetch_raw_response
      JSON.parse(fetch_raw_output)
    end
  end
end