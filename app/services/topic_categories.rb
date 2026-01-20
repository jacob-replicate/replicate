class TopicCategories
  CATEGORIES = {
    "Change Management" => %w[ci-cd feature-flags config-management migrations supply-chain],
    "Compute" => %w[resource-limits scheduling workload-isolation workload-state],
    "Storage" => %w[partitioning caching backups stale-reads consensus idempotency ordering transactions],
    "Networking" => %w[dns service-discovery load-balancing edge rate-limiting network-segmentation transport-security],
    "Observability" => %w[logging metrics tracing alerting],
    "Governance" => %w[iam compliance cost-optimization threat-detection change-approval data-retention vendor-risk],
  }.freeze

  def initialize(topics)
    @topics_by_code = topics.index_by(&:code)
  end

  def categorized
    @categorized ||= begin
      validate_topic_codes!
      CATEGORIES.map do |name, topic_codes|
        category_topics = topic_codes.map { |code| @topics_by_code[code] }.compact.sort_by(&:name)
        next if category_topics.empty?

        CategoryPresenter.new(
          name: name,
          topics: category_topics
        )
      end.compact.sort_by(&:name)
    end
  end

  def uncategorized
    categorized_codes = CATEGORIES.values.flatten
    @topics_by_code.values.reject { |t| categorized_codes.include?(t.code) }
  end

  private

  def validate_topic_codes!
    all_codes = CATEGORIES.values.flatten
    missing_codes = all_codes - @topics_by_code.keys
    if missing_codes.any?
      raise "TopicCategories contains codes that don't exist in the database: #{missing_codes.join(', ')}"
    end
  end


  CategoryPresenter = Struct.new(:name, :topics, keyword_init: true)
end