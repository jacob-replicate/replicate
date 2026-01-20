class TopicCategories
  CATEGORIES = {
    "Change Management" => %w[ci-cd feature-flags config-management migrations supply-chain],
    "Compute" => %w[resource-limits scheduling workload-isolation workload-state],
    "Storage" => %w[partitioning caching backups stale-reads consensus idempotency ordering transactions],
    "Networking" => %w[dns service-discovery load-balancing edge rate-limiting network-segmentation encryption],
    "Observability" => %w[logging metrics tracing alerting],
    "Governance" => %w[iam compliance cost-optimization threat-detection],
  }.freeze

  def initialize(topics)
    @topics_by_code = topics.index_by(&:code)
  end

  def categorized
    @categorized ||= CATEGORIES.map do |name, topic_codes|
      category_topics = topic_codes.map { |code| @topics_by_code[code] }.compact.sort_by(&:name)
      next if category_topics.empty?

      CategoryPresenter.new(
        name: name,
        topics: category_topics
      )
    end.compact.sort_by(&:name)
  end

  def uncategorized
    categorized_codes = CATEGORIES.values.flatten
    @topics_by_code.values.reject { |t| categorized_codes.include?(t.code) }
  end

  CategoryPresenter = Struct.new(:name, :topics, keyword_init: true)
end