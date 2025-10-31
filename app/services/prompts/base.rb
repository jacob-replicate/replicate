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
      fetch_valid_response
    end

    def validate(llm_output)
      nil
    end

    def fetch_valid_response
      30.times do
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
      raise if Rails.env.test?

      response = OpenAI::Client.new.chat.completions.create(
        messages: Array(@conversation&.message_history) + [{ role: "system", content: instructions }],
        model: "gpt-5-chat-latest",
      )

      content = response.choices.first.message[:content]
    end

    private

    def parse_formatted_elements(prefix: nil, suffix: nil)
      30.times do
        Rails.logger.info "Fetching LLM output for Conversation: #{@conversation&.id || 'N/A'}"
        raw_json = JSON.parse(fetch_raw_output) rescue {}
        Rails.logger.info raw_json.to_json
        raw_json = raw_json.with_indifferent_access
        elements = parse_elements(raw_json["elements"])
        return [prefix, elements, suffix].reject(&:blank?).join if elements.present?
      end
    end

    def parse_elements(elements)
      return nil if elements.blank?
      return nil unless Array(elements).any? { |element| Hash(element)["type"] == "paragraph" }
      Array(elements).reject(&:blank?).map do |element|
        element = Hash(element)
        if element["type"] == "paragraph"
          "<p>#{element["content"]}</p>".html_safe
        elsif element["type"] == "code"
          "<pre><code class='language-#{element['language'].to_s.gsub('language-', '')}'>#{element["content"]}</code></pre>".html_safe
        elsif element["type"] == "line_chart"
          chart_id = "visual-#{rand(1_000_000)}"
          content = Hash(element["content"])
          labels = content["x_axis_labels"].to_json
          series_data = content["series"] # e.g. [{"name"=>"Retries", "data"=>[...]}, ...]

          highlight_ranges = (content["highlight_ranges"] || [])
          mark_area_data = highlight_ranges.map do |range|
            %Q|[
          { xAxis: "#{range["start"]}" },
          { xAxis: "#{range["end"]}" }
        ]|
          end.join(",\n")

          series_blocks = Array(series_data).map do |s|
            mark_area = if highlight_ranges.any?
              %Q|,
          markArea: {
            itemStyle: { color: 'rgba(255, 173, 177, 0.4)' },
            data: [#{mark_area_data}]
          }|
            else
              ""
            end

            %Q|{
          name: "#{s["name"]}",
          type: "line",
          smooth: true,
          stack: "Total",
          data: #{s["data"].to_json}#{mark_area}
        }|
          end.join(",\n")

          legend_data = series_data.map { |s| "\"#{s["name"]}\"" }.join(", ")

          line_chart = <<~HTML
        <div id="#{chart_id}" style="width: 100%; height: 400px;"></div>
        <script>
          setTimeout(function() { 
            var chartDom = document.getElementById("#{chart_id}");
            var myChart = echarts.init(chartDom);
            var option = {
              title: {
                text: "#{content["title"]}"
              },
              tooltip: { trigger: "axis", axisPointer: { type: "cross" } },
              legend: { data: [#{legend_data}] },
              xAxis: {
                type: "category",
                boundaryGap: false,
                data: #{labels}
              },
              yAxis: {
                type: "value",
                axisPointer: { snap: true }
              },
              series: [#{series_blocks}]
            };
            myChart.setOption(option);
          }, 100);
        </script>
      HTML
        line_chart.html_safe
      else nil
        end
      end.reject(&:blank?).join.html_safe
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

      prompt_instructions
    end
  end
end