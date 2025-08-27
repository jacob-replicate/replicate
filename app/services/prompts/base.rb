module Prompts
  class Base
    @@template_cache ||= {}

    def initialize(conversation: nil, context: {})
      @conversation = conversation
      @context = context

      if @context.blank? && @conversation.present?
        @context = @conversation.context || {}
      end
    end

    def call
      fetch_valid_response
    end

    def validate(llm_output)
      nil
    end

    def fetch_valid_response
      10.times do
        llm_output = SanitizeAiContent.call(fetch_raw_output)
        error = validate(llm_output)

        if error.present?
          Rails.logger.error "Prompt Failure for #{template_name} - Conversation: #{@conversation&.id || 'N/A'}: #{error}"
        else
          return llm_output
        end
      end

      nil
    end

    def fetch_raw_output
      response = OpenAI::Client.new.chat.completions.create(
        messages: Array(@conversation&.message_history) + [{ role: "system", content: instructions }],
        model: "gpt-4o-2024-11-20"
      )

      content = response.choices.first.message[:content]
    end

    private

    def template_name
      self.class.name.demodulize.underscore
    end

    def template(name: nil, shared: false)
      name ||= template_name
      cache_key = shared ? "shared/#{name}" : name

      if @@template_cache.key?(cache_key) && Rails.env.production?
        return @@template_cache[cache_key]
      end

      full_path = shared ?
        Rails.root.join("app", "prompts", "shared", "#{name}.txt") :
        Rails.root.join("app", "prompts", "#{name}.txt")
      return nil unless File.exist?(full_path)

      text = File.read(full_path)
      @@template_cache[cache_key] = text
    end

    def instructions
      prompt_instructions = template&.dup
      return "" if prompt_instructions.blank?

      Dir.glob(Rails.root.join('app', 'prompts', 'shared', '*.txt')).each do |file|
        name = File.basename(file, '.txt')
        prompt_instructions.gsub!("{{#{name.upcase}}}", template(name: name, shared: true))
      end

      @context.each { |key, val| prompt_instructions.gsub!("{{CONTEXT_#{key.upcase}}}", val.to_s) }

      prompt_instructions
    end
  end
end