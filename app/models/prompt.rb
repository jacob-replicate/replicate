# Usage: Prompt.new(:landing_page_incident, input: { incident: "We crashed PostgreSQL" }).call

class Prompt
  def initialize(prompt_code, input: nil)
    @prompt_code = prompt_code.to_s.gsub(BANNED_TERMS_REGEX, "")
    @input = input
  end

  # TODO: Add retry logic
  def execute
    return nil unless @prompt_code.present?

    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [{ role: "user", content: instructions}],
        temperature: 0.7,
      })

    response.dig("choices", 0, "message", "content")
  end

  def stream
    return nil unless @prompt_code.present?

    client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [{ role: "user", content: instructions }],
        temperature: 0.7,
        stream: proc do |chunk|
          message = chunk.dig("choices", 0, "delta", "content")
          yield message if message.present?
        end
      }
    )
  end

  private

  def sanitize(prompt_code)
    BANNED_TERMS.each do |term|
      prompt_code.gsub!(term, "")
    end
  end

  def client
    OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end

  def instructions
    valid_instructions_names = Dir.glob(Rails.root.join('app', 'prompts', '*.txt')).map { |x| x.split("/").last.gsub(".txt", "") }
    return nil unless valid_instructions_names.include?(@prompt_code.to_s)

    instructions = File.read(Rails.root.join('app', 'prompts', "#{@prompt_code}.txt"))

    shared_instructionss = Dir.glob(Rails.root.join('app', 'prompts', 'shared', '*.txt')).each do |file|
      file_name = File.basename(file, '.txt')
      instructions.gsub!("{{#{file_name.upcase}}}", File.read(file))
    end

    Hash(@input).each do |input_key, input_value|
      instructions.gsub!("{{INPUT_#{input_key.upcase}}}", input_value)
    end

    instructions
  end
end