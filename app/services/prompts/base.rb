module Prompts
  class Base
    @@template_cache ||= {}

    def initialize(conversation: nil, context: {}, cacheable: false, force_cache: false)
      @conversation = conversation
      @context = context

      if @context.present?
        @context = @context.merge(@conversation.context || {}).with_indifferent_access if @conversation.present?
      end

      if @context.blank? && @conversation.present?
        @context = @conversation.context&.with_indifferent_access || {}.with_indifferent_access
      end

      @cacheable = cacheable
      @force_cache = force_cache

      @inputs = Prompts::Base.build_inputs(
        conversation_type: @context["conversation_type"],
        difficulty: @context["difficulty"],
        incident: @context["incident"],
        prompt_for_ai: @context["prompt_for_ai"],
        title: @context["title"]
      )

      @context[:current_time] = Time.current.utc.to_s
    end

    def call
      parallel_batch_process do |elements|
        paragraphs = elements.select { |e| Hash(e).with_indifferent_access[:type] == "paragraph" }.map { |e| SanitizeAiContent.call(e.with_indifferent_access[:content].to_s) }
        paragraphs_not_too_long = paragraphs.all? { |p| p.length <= 500 && p.exclude?("*") }
        first_element_is_paragraph = Hash(elements.first)["type"] == "paragraph"
        last_element_is_paragraph = Hash(elements.last)["type"] == "paragraph"

        paragraphs_not_too_complex = paragraphs.all? do |p|
          words = p.scan(/\b[a-zA-Z']+\b/)
          big_word_ratio = words.count { |w| w.length >= 10 }.to_f / [words.size, 1].max
          big_word_ratio < 0.25
        end

        code_blocks_valid = elements.select { |e| Hash(e).with_indifferent_access[:type] == "code" }.all? do |e|
          e = e.with_indifferent_access
          e[:content].is_a?(String) && e[:file].is_a?(String) && e[:file].length <= 100 && e[:language].is_a?(String) && e[:language].to_s.downcase != "ruby"
        end

        valid =
          elements.size.positive? &&
            code_blocks_valid &&
            paragraphs_not_too_long &&
            paragraphs_not_too_complex &&
            paragraphs.size >= 1

        # Logging if invalid
        unless valid
          failures = []
          failures << "no_elements" if elements.size.zero?
          failures << "code_blocks_invalid" unless code_blocks_valid
          failures << "paragraphs_too_long" unless paragraphs_not_too_long
          failures << "paragraphs_too_complex" unless paragraphs_not_too_complex
          failures << "first_element_not_paragraph" unless first_element_is_paragraph

          if Rails.env.development?
            Rails.logger.warn("Prompt validation failed for #{template_name}: #{elements.to_json} - #{failures.join(', ')} | paragraphs=#{paragraphs.inspect.truncate(300)}")
          end
        end

        valid
      end
    end

    def fetch_raw_output
      raise if Rails.env.test?

      start_time = Time.now.to_i
      response = OpenAI::Client.new.chat.completions.create(
        messages: Array(@conversation&.message_history) + [{ role: "system", content: instructions }],
        model: "gpt-4o-2024-11-20"
      )

      if Rails.env.development?
        Rails.logger.info "Prompt Response Time: #{template_name} - #{Time.now.to_i - start_time}"
      end

      response.choices.first.message[:content] rescue nil
    end

    def parallel_batch_process(starting_batch_size: 8, format: true, &validation_block)
      result = Queue.new

      if @cacheable && !@force_cache && !(Rails.env.development? || Rails.env.test?)
        cached_response = CachedLlmResponse.where(template_name: template_name, input_hash: @inputs["input_hash"]).order(:updated_at).last
        return cached_response.response if cached_response.present?
      end

      if @conversation&.turn.to_i >= 5
        starting_batch_size = 3
      end

      [starting_batch_size, 6, 8, 10, 10, 10].each do |batch|
        threads = []
        batch.times do
          threads << Thread.new do
            begin
              raw_response = fetch_raw_response
              if validation_block.call(raw_response)
                result << (format ? format_raw_response(raw_response) : raw_response)
              end
            rescue => e
              Rails.logger.error("[#{template_name}] Thread Failed (batch=#{batch}, turn=#{@conversation&.turn}) failed: #{e.class} - #{e.message}")

              if Rails.env.development?
                raise e
              end
            end
          end
        end

        value = nil
        begin
          Timeout.timeout(10) { value = result.pop }
        rescue Timeout::Error
        end

        threads.each(&:kill)
        if value
          CachedLlmResponse.create!(template_name: template_name, inputs: @inputs, input_hash: @inputs["input_hash"], response: value) if @cacheable
          return value
        end
      end

      []
    end

    # TODO: Refactor this to GiveCampus "unique_fields"-style concept. Make it a collection or something less hardcoded.
    def self.build_inputs(conversation_type:, difficulty:, incident: nil, title: nil, prompt_for_ai: nil)
      conversation_type = conversation_type.to_s.strip.downcase
      difficulty = difficulty.to_s.strip.downcase

      sanitized_inputs = {
        "conversation_type" => conversation_type,
        "difficulty" => difficulty,
        "difficulty_prompt" => difficulty_prompts[difficulty],
        "incident" => incident.to_s.downcase.squish, # TODO: Merge with prompt_for_ai
        "title" => title.to_s.downcase.squish,
        "prompt_for_ai" => prompt_for_ai.to_s.downcase.squish
      }

      hashed_inputs = Digest::SHA256.hexdigest(sanitized_inputs.to_json)
      sanitized_inputs["input_hash"] = hashed_inputs
      sanitized_inputs["incident"] = incident.to_s.squish
      sanitized_inputs["prompt_for_ai"] = prompt_for_ai.to_s.squish
      sanitized_inputs["title"] = title.to_s.squish

      Rails.logger.info "[Prompts::Base] Built Inputs: #{sanitized_inputs.inspect}" if Rails.env.development?

      sanitized_inputs
    end

    def self.difficulty_prompts
      {
        "junior" => "You're working with a junior full-stack web application engineer at a fast-paced midmarket company. They don't know much about cloud-native computing at all. Keep it friendly, concrete, and free of jargon. Think mentorship, not mastery. They don't know the big words yet. Don't use them. Assume they suck at resolving SEV-1 incidents. You need to hand-hold. Dumb it down. No word salad.",
        "mid" => "You’re working with a mid-level SRE at a fast-paced midmarket company. Assume they know the basics but not the edge cases. Use plain technical terms and connect each detail to practical outcomes. Explain tradeoffs and reliability patterns without diving into deep distributed systems theory. They're stronger than juniors, but not by much yet. No word salad. Dumb it down if you need to.",
        "senior" => "You're talking to a senior SRE at a fast-paced midmarket company. Skip the hand-holding. Assume fluency in systems, networking, and incident response, but still weak spots in areas that Staff+ would excel at. Use precise technical language and emphasize nuance (e.g., where guarantees break, where intuition fails, how design choices cascade under load). No word salad.",
        "staff" => "You’re working with a Staff+ engineer at a fast-paced midmarket company. Treat them as a peer. Be exact, economical, and challenging. Focus on causal reasoning, trust boundaries, system failure modes, etc. No hand waving. Precision and insight matter more than style. If they don't know something, they'll google it. Assume high levels of technical competence."
      }
    end

    private

    def fetch_raw_response
      raw_output = fetch_raw_output.gsub("```json", "").gsub("```", "").strip

      if Rails.env.development?
        Rails.logger.info "[#{template_name}] Raw Output: #{raw_output}"
      end

      raw_json = JSON.parse(raw_output) rescue {}
      elements = Array(raw_json.with_indifferent_access[:elements]).map(&:with_indifferent_access) || []

      elements.map do |element|
        if element[:type] == "paragraph"
          element[:content] = element[:content].gsub("*", "")
        end

        element
      end
    end

    def prefix
      ""
    end

    def suffix
      ""
    end

    def format_raw_response(elements)
      formatted_elements = []
      formatted_elements << prefix.html_safe unless prefix.blank?

      formatted_elements += Array(elements).reject(&:blank?).map do |element|
        type = element.is_a?(Hash) ? element.with_indifferent_access[:type] : element.class

        if type == String
          element
        elsif type == "paragraph"
          "<p>#{element["content"]}</p>".html_safe
        elsif type == "code"
          code = ""
          file_name = element["file"]
          if file_name.present?
            code += "<div class='file-name'>#{file_name.split("#").map { |x| x.include?("/") ? x : "<span class='font-semibold'>#{x}</span>" }.join(" - ")}</div>" if file_name
          end
          code += "<pre><code class='language-#{element['language'].to_s.gsub('language-', '')}'>#{element["content"].gsub("\t", "  ")}</code></pre>".html_safe
          code
        else
          Rails.logger.warn("[#{template_name}] Unknown element type: #{type.inspect}")
          nil
        end
      end.reject(&:blank?)

      Rails.logger.info "[#{template_name}] Formatted Elements Before Suffix: #{formatted_elements.inspect}" if Rails.env.development?
      Rails.logger.info "suffix: #{suffix.inspect}" if Rails.env.development?
      unless suffix.blank?
        formatted_elements << suffix.html_safe
      end

      Rails.logger.info "[#{template_name}] Formatted Elements: #{formatted_elements.join.truncate(500)}" if Rails.env.development?

      formatted_elements.join.html_safe
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