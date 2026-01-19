class TopicCategories
  CATEGORIES = {
    "Change Management" => {
      description: "Shipping is the easy part. Realizing you can't roll back the schema migration is not.",
      topics: %w[ci-cd feature-flags config-management supply-chain]
    },
    "Compute" => {
      description: "",
      topics: %w[resource-limits scheduling isolation workload-state]
    },
    "Storage" => {
      description: "",
      topics: %w[database-ops migrations partitioning caching backups stale-reads consensus idempotency ordering transactions]
    },
    "Networking" => {
      description: "",
      topics: %w[dns service-discovery load-balancing edge rate-limiting network-security encryption identity]
    },
    "Observability" => {
      description: "",
      topics: %w[logging metrics tracing alerting debugging]
    },
    "Governance" => {
      description: "",
      topics: %w[iam compliance cost threat-detection security-incidents]
    },
  }.freeze

  def initialize(topics)
    @topics_by_code = topics.index_by(&:code)
  end

  def categorized
    @categorized ||= CATEGORIES.map do |name, config|
      category_topics = config[:topics].map { |code| @topics_by_code[code] }.compact.sort_by(&:name)
      next if category_topics.empty?

      CategoryPresenter.new(
        name: name,
        description: config[:description],
        topics: category_topics
      )
    end.compact.sort_by(&:name)
  end

  def uncategorized
    categorized_codes = CATEGORIES.values.flat_map { |c| c[:topics] }
    @topics_by_code.values.reject { |t| categorized_codes.include?(t.code) }
  end

  CategoryPresenter = Struct.new(:name, :description, :topics, keyword_init: true)
end