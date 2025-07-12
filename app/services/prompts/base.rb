module Prompts
  class Base
    @@template_cache ||= {}

    def initialize(conversation:)
      @conversation = conversation
    end

    def call
      fetch_valid_response
    end

    def validate(llm_output)
      nil
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

      response.dig("choices", 0, "message", "content").to_s.gsub("<pre>", "").gsub("</pre>", "")
    end

    private

    def template_name
      self.class.name.demodulize.underscore
    end

    def template(name: nil, shared: false)
      name ||= template_name
      cache_key = shared ? "shared/#{name}" : name
      return @@template_cache[cache_key] if @@template_cache.key?(cache_key)

      full_path = shared ?
        Rails.root.join("app", "prompts", "shared", "#{name}.txt") :
        Rails.root.join("app", "prompts", "#{name}.txt")
      return nil unless File.exist?(full_path)

      text = File.read(full_path)
      @@template_cache[cache_key] = text
    end

    def client
      OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    end

    def instructions
      prompt_instructions = template&.dup
      return "" if prompt_instructions.blank?

      Dir.glob(Rails.root.join('app', 'prompts', 'shared', '*.txt')).each do |file|
        name = File.basename(file, '.txt')
        prompt_instructions.gsub!("{{#{name.upcase}}}", template(name: name, shared: true))
      end

      @conversation.context.each { |key, val| prompt_instructions.gsub!("{{CONTEXT_#{key.upcase}}}", val.to_s) }

      prompt_instructions
    end
  end
end