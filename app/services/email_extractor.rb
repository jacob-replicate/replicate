class EmailExtractor
  def self.call(raw_input)
    return [] if raw_input.blank?

    raw_input
      .to_s
      .downcase
      .scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i)
      .uniq
  end
end