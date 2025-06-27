class Chunker
  def self.split(text, max_tokens: 150)
    return [] if text.blank?

    # Split on paragraph boundaries first
    paragraphs = text.split(/\n{2,}/).map(&:strip)
    chunks = []
    buffer = ""

    paragraphs.each do |para|
      if (buffer + para).length > max_tokens * 4 # ~4 chars per token
        chunks << buffer.strip unless buffer.empty?
        buffer = para
      else
        buffer += "\n\n#{para}"
      end
    end

    chunks << buffer.strip unless buffer.empty?

    # If we only got 1 massive chunk, fallback to fixed-length slicing
    if chunks.size == 1 && chunks.first.length > max_tokens * 4
      text.scan(/.{1,#{max_tokens * 4}}/m).map(&:strip)
    else
      chunks
    end
  end
end