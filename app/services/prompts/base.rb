module Prompts
  class Base
    @@template_cache ||= {}

    def initialize(context: {}, message_history: [])
      @context = context.with_indifferent_access
      @message_history = message_history
      @context[:current_time] = Time.current.utc.to_s
    end

    def call
      run_batch_process
    end

    def fetch_llm_response
      raise if Rails.env.test?

      start_time = Time.now.to_i
      response = OpenAI::Client.new.chat.completions.create(
        messages: @message_history + [{ role: "system", content: instructions }],
        model: "gpt-4o-2024-11-20"
      )

      if Rails.env.development?
        Rails.logger.info "Prompt Response Time: #{template_name} - #{Time.now.to_i - start_time}"
      end

      response.choices.first.message[:content] rescue nil
    end

    def self.extract_json(raw_output)
      json_match = raw_output.match(/```json\s*(\{.*?\})\s*```/m) ||
                   raw_output.match(/```\s*(\{.*?\})\s*```/m) ||
                   raw_output.match(/(\{.*\})/m)

      json_string = json_match ? json_match[1] : raw_output

      JSON.parse(json_string).with_indifferent_access
    rescue
      {}
    end

    def run_batch_process(starting_batch_size: 8)
      result = Queue.new
      errors = Queue.new

      return [] if Rails.env.test?

      starting_batch_size = 3 if @message_history.size >= 10

      [starting_batch_size, 6, 8, 10, 10, 10].each_with_index do |batch, batch_index|
        threads = []
        batch.times do
          threads << Thread.new do
            begin
              raw = fetch_llm_response
              validation_errors = validate(raw)
              if validation_errors.empty?
                result << parse_response(raw)
              else
                errors << { type: :validation, errors: validation_errors, raw: raw }
              end
            rescue => e
              errors << { type: :exception, error: e, message: "#{e.class} - #{e.message}" }
            end
          end
        end

        value = nil
        begin
          Timeout.timeout(10) { value = result.pop }
        rescue Timeout::Error
          errors << { type: :timeout, batch: batch, batch_index: batch_index }
        end

        threads.each(&:kill)

        if value
          log_batch_errors(errors, batch_index) if Rails.env.development?
          return value
        end
      end

      log_batch_errors(errors, "final") if Rails.env.development?
      []
    end

    def log_batch_errors(errors, batch_info)
      return if errors.empty?

      collected_errors = []
      collected_errors << errors.pop until errors.empty?

      return if collected_errors.empty?

      Rails.logger.warn("[#{template_name}] Batch #{batch_info} completed with #{collected_errors.size} issue(s):")
      collected_errors.each_with_index do |err, i|
        case err[:type]
        when :validation
          Rails.logger.warn("  [#{i + 1}] Validation failed: #{err[:errors].inspect}")
          Rails.logger.debug("  [#{i + 1}] Raw response: #{err[:raw]&.truncate(500)}")
        when :exception
          Rails.logger.warn("  [#{i + 1}] Exception: #{err[:message]}")
        when :timeout
          Rails.logger.warn("  [#{i + 1}] Timeout waiting for result (batch=#{err[:batch]})")
        end
      end
    end

    def parse_response(raw)
      Prompts::Base.extract_json(raw)
    rescue JSON::ParserError
      {}
    end

    def validate(raw)
      []
    end

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
      prompt_instructions.gsub!("{{CONTEXT_CUSTOM_INSTRUCTIONS}}", "")

      prompt_instructions
    end
  end
end