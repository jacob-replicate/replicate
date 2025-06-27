class Retriever
  def self.find_relevant_chunks(query, max_results: 3, min_score: -0.20)
    embedding = Embedder.embed(query)

    results = PromptChunk
      .select("content, embedding <#> '[#{embedding.join(',')}]' AS score")
      .order("score ASC")
      .limit(max_results)
      .map { |r| { content: r.content, score: r.score.to_f } }

    # Filter by score threshold
    results.select { |r| r[:score] <= min_score }
  end
end