module Prompts
  class Base
    def initialize(conversation:)
      @conversation = conversation
    end

    def call
      fetch_valid_response
    end

    def validate(llm_output)
      true
    end

    def fetch_valid_response
      10.times do
        llm_output = fetch_raw_output
        error = validate(llm_output)

        if error.present?
          Rails.logger.error "Prompt Failure for #{template_name} - Conversation: #{@conversation.id}: #{error}"
        else
          return llm_output
        end
      end

      nil
    end

    def fetch_raw_output
      response = client.chat(
        parameters: {
          model: "gpt-4o-2024-11-20",
          messages: @conversation.message_history + [{ role: "system", content: instructions }],
          temperature: 0.3,
        }
      )

      response.dig("choices", 0, "message", "content")
    end

    private

    def template_name
      self.class.name.demodulize.underscore
    end

    def client
      OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    end

    def instructions
      valid_names = Dir.glob(Rails.root.join('app', 'prompts', '*.txt')).map { |x| File.basename(x, '.txt') }
      return nil unless valid_names.include?(template)

      instructions = File.read(Rails.root.join('app', 'prompts', "#{template}.txt"))

      Dir.glob(Rails.root.join('app', 'prompts', 'shared', '*.txt')).each do |file|
        name = File.basename(file, '.txt').upcase
        instructions.gsub!("{{#{name}}}", File.read(file)) # TODO: Replace this one day? Lots of disk reads.
      end

      Hash(@context).each do |key, val|
        instructions.gsub!("{{CONTEXT_#{key.upcase}}}", val.to_s)
      end

      instructions
    end
  end
end