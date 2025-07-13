chunks = [
]

chunks.each_with_index do |text, i|
  embedding = Embedder.embed(text)

  PromptChunk.create!(
    content: text.strip,
    embedding: "[#{embedding.join(',')}]"
  )
end