module Prompts
  class Base
    @@template_cache ||= {}

    def initialize(conversation: nil, context: {})
      @conversation = conversation
      @context = context

      if @context.present?
        @context = @context.merge(@conversation.context || {}) if @conversation.present?
      end

      if @context.blank? && @conversation.present?
        @context = @conversation.context || {}
      end

      @context[:current_time] = Time.current.utc.to_s
    end

    def call
      parallel_batch_process do |elements|
        paragraphs = elements.select { |e| Hash(e).with_indifferent_access[:type] == "paragraph" }.map { |e| e.with_indifferent_access[:content].to_s }
        paragraphs_not_too_long = paragraphs.all? { |p| p.length <= 500 && p.exclude?("*") }
        last_element_is_paragraph = Hash(elements.last)["type"] == "paragraph"

        elements.size > 0 && paragraphs_not_too_long && last_element_is_paragraph
      end
    end

    def fetch_raw_output
      raise if Rails.env.test?

      start_time = Time.now.to_i
      response = OpenAI::Client.new.chat.completions.create(
        messages: Array(@conversation&.message_history) + [{ role: "system", content: instructions }],
        model: "gpt-5-chat-latest",
      )
      Rails.logger.info "Prompt Response Time: #{template_name} - #{Time.now.to_i - start_time}"

      response.choices.first.message[:content]
    end

    def parallel_batch_process(starting_batch_size: 4, format: true, &validation_block)
      result = Queue.new

      if @conversation.turn >= 5
        starting_batch_size = 3
      end

      [starting_batch_size, 6, 8, 10].each do |batch|
        Rails.logger.info "Thread Batch: #{batch}"
        threads = []
        batch.times do
          threads << Thread.new do
            begin
              elements = fetch_elements
              if validation_block.call(elements)
                result << (format ? format_elements(elements) : elements)
              end
            rescue => e
              Rails.logger.error("Thread failed: #{e.message}")
            end
          end
        end

        value = nil
        begin
          Timeout.timeout(10) { value = result.pop }
        rescue Timeout::Error
        end

        threads.each(&:kill)
        return value if value
      end

      []
    end

    private

    def fetch_elements
      raw_json = JSON.parse(fetch_raw_output) rescue {}
      Array(raw_json.with_indifferent_access[:elements]).map(&:with_indifferent_access) || []
    end

    def prefix
      ""
    end

    def suffix
      ""
    end

    def format_elements(elements)
      formatted_elements = []
      formatted_elements << prefix.html_safe unless prefix.blank?

      formatted_elements += Array(elements).reject(&:blank?).map do |element|
        type = element.is_a?(Hash) ? element.with_indifferent_access[:type] : element.class

        if type == String
          element
        elsif type == "paragraph"
          "<p>#{element["content"]}</p>".html_safe
        elsif type == "code"
          "<pre><code class='language-#{element['language'].to_s.gsub('language-', '')}'>#{element["content"]}</code></pre>".html_safe
        else
          nil
        end
      end.reject(&:blank?)

      formatted_elements << suffix.html_safe unless suffix.blank?

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