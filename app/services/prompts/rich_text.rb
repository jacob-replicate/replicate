module Prompts
  module RichText
    def self.parse(raw_output)
      raw_output = raw_output.gsub("```json", "").gsub("```", "").strip
      raw_json = JSON.parse(raw_output) rescue {}
      elements = Array(raw_json.with_indifferent_access[:elements]).map(&:with_indifferent_access) || []

      elements.map do |element|
        if element[:type] == "paragraph"
          element[:content] = element[:content].gsub("*", "")
        end
        element
      end
    end

    def self.format(elements, prefix: "", suffix: "")
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
            code += "<div class='file-name'>#{file_name.split("#").map { |x| x.include?("/") ? x : "<span class='font-semibold'>#{x}</span>" }.join(" - ")}</div>"
          end
          code += "<pre><code class='language-#{element['language'].to_s.gsub('language-', '')}'>#{element["content"].gsub("\t", "  ")}</code></pre>".html_safe
          code
        end
      end.compact

      formatted_elements << suffix.html_safe unless suffix.blank?

      formatted_elements.join.html_safe
    end

    def self.validate(elements)
      failures = []

      paragraphs = elements.select { |e| Hash(e).with_indifferent_access[:type] == "paragraph" }.map { |e| SanitizeAiContent.call(e.with_indifferent_access[:content].to_s) }

      failures << "no_elements" if elements.size.zero?
      failures << "no_paragraphs" if paragraphs.size < 1

      paragraphs.each_with_index do |p, idx|
        failures << "paragraph_#{idx}_too_long" if p.length > 500
        failures << "paragraph_#{idx}_has_asterisks" if p.include?("*")
        failures << "paragraph_#{idx}_has_backticks" if p.include?("`")

        words = p.scan(/\b[a-zA-Z']+\b/)
        big_word_ratio = words.count { |w| w.length >= 10 }.to_f / [words.size, 1].max
        failures << "paragraph_#{idx}_too_complex" if big_word_ratio >= 0.25
      end

      elements.select { |e| Hash(e).with_indifferent_access[:type] == "code" }.each_with_index do |e, idx|
        e = e.with_indifferent_access
        failures << "code_#{idx}_invalid" unless e[:content].is_a?(String) && e[:file].is_a?(String) && e[:file].length <= 100 && e[:language].is_a?(String) && e[:language].to_s.downcase != "ruby"
      end

      failures
    end
  end
end