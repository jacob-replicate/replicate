class TopicCategories
  CATEGORIES = {
    "Traffic" => {
      description: "A request hits your load balancer and vanishes. The DNS was stale, but you won't know that for an hour.",
      topics: %w[dns service-discovery load-balancing edge rate-limiting]
    },
    "Network Security" => {
      description: "Every service needs to prove its identity. Misconfigured trust is how breaches happen.",
      topics: %w[network-security encryption identity]
    },
    "Security Operations" => {
      description: "Audits, compliance, incident response, and proving your security isn't just vibes.",
      topics: %w[threat-detection security-incidents compliance supply-chain]
    },
    "Data Consistency" => {
      description: "",
      topics: %w[stale-reads consensus idempotency ordering transactions]
    },
    "Database Operations" => {
      description: "Latency creeps up quietly for months. Then suddenly your p99 owns your on-call rotation.",
      topics: %w[database-ops partitioning caching backups]
    },
    "Shipping Changes" => {
      description: "Shipping is the easy part. Realizing you can't roll back the schema migration is not.",
      topics: %w[ci-cd migrations feature-flags config-management]
    },
    "Compute" => {
      description: "",
      topics: %w[resource-limits scheduling isolation workload-state]
    },
    "Reliability" => {
      description: "The pager goes off at 3am because someone decided the alert could wait until after launch.",
      topics: %w[capacity observability incidents cost]
    }
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