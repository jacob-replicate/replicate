class Prompt
  def initialize(prompt_code, input: nil, history: [])
    @prompt_code = prompt_code.to_s.gsub(BANNED_TERMS_REGEX, "")
    @input = input || {}
    @history = Array(history).map { |m| { role: m[:role], content: m[:content].to_s } }
  end

  def execute
    return nil unless @prompt_code.present?

    response = client.chat(
      parameters: {
        model: "gpt-4.1",
        messages: messages,
        temperature: 0.7,
      }
    )

    response.dig("choices", 0, "message", "content")
  end

  def stream
    return nil unless @prompt_code.present?

    client.chat(
      parameters: {
        model: "gpt-4o",
        messages: messages,
        temperature: 0.7,
        stream: proc do |chunk|
          message = chunk.dig("choices", 0, "delta", "content")
          yield message if message.present?
        end
      }
    )
  end

  private

  def client
    OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end

  def messages
    filtered_history = @history.select { |m| m[:content].present? }
    filtered_history + [{ role: "system", content: instructions }]
  end

  def instructions
    valid_names = Dir.glob(Rails.root.join('app', 'prompts', '*.txt')).map { |x| File.basename(x, '.txt') }
    return nil unless valid_names.include?(@prompt_code)

    instructions = File.read(Rails.root.join('app', 'prompts', "#{@prompt_code}.txt"))

    # Inject shared sections (e.g. PLATFORM_OVERVIEW)
    Dir.glob(Rails.root.join('app', 'prompts', 'shared', '*.txt')).each do |file|
      name = File.basename(file, '.txt').upcase
      instructions.gsub!("{{#{name}}}", File.read(file))
    end

    # Inject user-provided variables
    Hash(@input).each do |key, val|
      instructions.gsub!("{{INPUT_#{key.upcase}}}", val.to_s)
    end

    # Inject relevant context only if {{RETRIEVED_CONTEXT}} exists
    if instructions.include?("{{RETRIEVED_CONTEXT}}")
      query_text = @input[:message] || @input[:incident] || ""
      instructions.gsub!("{{RETRIEVED_CONTEXT}}", Retriever.find_relevant_chunks(query_text).join("\n\n"))
    end

    instructions
  end
end