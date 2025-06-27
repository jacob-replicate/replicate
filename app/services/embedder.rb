class Embedder
  def self.embed(text)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    response = client.embeddings(
      parameters: {
        model: "text-embedding-3-large",
        input: text
      }
    )

    response.dig("data", 0, "embedding")
  end
end