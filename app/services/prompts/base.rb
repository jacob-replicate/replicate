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

      avatar = "<div class='flex items-center mb-3 gap-3'><div style='width: 32px'><img src='/jacob-square.jpg' class='rounded-full' /></div><div class='font-medium'>Jacob Comer</div></div>"
      avatar = "<div class='flex items-center mb-3 gap-3'><div style='width: 32px'><img src='/jacob-square.jpg' class='rounded-full' /></div><div class='font-medium'>Jacob Comer</div></div>"
      avatars = [
        coach_avatar_row(first: true),
        coach_avatar_row,
        avatar_row(name: "Taylor Morales"),
        avatar_row(name: "Casey Patel"),
        avatar_row(name: "Alex Shaw")
      ]
      response = response.dig("choices", 0, "message", "content").to_s
      response.gsub!(/<\br>\s*<br\s*\/?>/, "</div>")
      response.gsub!(/<\/div>\s*<br\s*\/?>/, "</div>")
      response.gsub!("```html", "")
      response.gsub!("```", "")
      response.gsub!("`", "")
      response.gsub!(avatar, "")
      avatars.each do |avatar|
        response.gsub!(avatar, "")
      end

      response
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

    def coach_avatar_row(first: false)
      avatar_row(first: first)
    end

    def student_avatar_row
      engineer_name = @conversation.context["engineer_name"]

      photo_id = if engineer_name.include?("Alex")
        1
      elsif engineer_name.include?("Casey")
        2
      else
        3
      end

      avatar_row(name: engineer_name, photo_path: "profile-photo-#{photo_id}.jpg")
    end

    def avatar_row(name: "Jacob Comer", photo_path: "jacob-square.jpg", first: false)
      "<div class='mb-4'><div class='flex items-center gap-3'><div style='width: 32px'><img src='/#{photo_path}' class='rounded-full' /></div><div class='font-medium'>#{name}</div></div></div>"
    end
  end
end