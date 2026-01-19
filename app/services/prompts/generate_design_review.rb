module Prompts
  class GenerateDesignReview < Prompts::Base
    def validate(raw)
      raw_json = Prompts::Base.extract_json(raw)
      failures = []

      failures << "raw_json_not_hash" unless raw_json.is_a?(Hash)
      failures << "missing_design_review" unless raw_json["design_review"].is_a?(Hash)

      if raw_json["design_review"].is_a?(Hash)
        review = raw_json["design_review"]

        unless review["title"].is_a?(String) && !review["title"].strip.empty?
          failures << "review_missing_title"
        end

        if review["title"].is_a?(String) && review["title"].length > 60
          failures << "review_title_too_long"
        end

        unless review["subtitle"].is_a?(String) && !review["subtitle"].strip.empty?
          failures << "review_missing_subtitle"
        end

        if review["subtitle"].is_a?(String) && review["subtitle"].length > 80
          failures << "review_subtitle_too_long"
        end

        unless review["body"].is_a?(String) && !review["body"].strip.empty?
          failures << "review_missing_body"
        end

        if review["body"].is_a?(String)
          failures << "review_body_missing_html" unless review["body"].include?("<div>")
          failures << "review_body_missing_code" unless review["body"].include?("<code")

          # Validate language is from allowed list
          allowed_languages = %w[python go typescript bash hcl json sql yaml plaintext]
          language_match = review["body"].match(/language-(\w+)/)
          if language_match && !allowed_languages.include?(language_match[1])
            failures << "review_body_invalid_language"
          end

          # Extract text outside of code blocks and check length (~400 chars for two ~200 char paragraphs)
          text_outside_code = review["body"].gsub(/<pre>.*?<\/pre>/m, "").gsub(/<[^>]+>/, "").gsub(/\s+/, " ").strip
          if text_outside_code.length > 500
            failures << "review_body_text_too_long"
          end
        end

        unless review["input_placeholder"].is_a?(String) && !review["input_placeholder"].strip.empty?
          failures << "review_missing_input_placeholder"
        end

        unless review["generation_intent"].is_a?(String) && !review["generation_intent"].strip.empty?
          failures << "review_missing_generation_intent"
        end
      end

      failures
    end

    def template_name
      "generate_design_review"
    end
  end
end