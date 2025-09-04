class EmailExtractor
  def self.call(raw_input)
    raw_input.to_s
      .squish
      .downcase
      .split(/[\n, ;]+/)
      .map(&:strip)
      .reject(&:blank?)
      .select { |e| e.match?(URI::MailTo::EMAIL_REGEXP) }
      .uniq
  end
end