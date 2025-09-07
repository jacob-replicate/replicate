class FetchContactScheduler
  def self.call(job_title_keywords = [])
    if job_title_keywords.blank?
      job_title_keywords = leadership_keywords
    end

    job_title_keywords.map(&:downcase).uniq.each_with_index do |keyword, i|
      ScheduleContactFetchingWorker.perform_in((i * 2).minutes, keyword)
    end
  end

  def self.ic_keywords
     [
      "backend",
      "cloud",
      "infrastructure",
      "internal tools",
      "lead",
      "observability",
      "platform",
      "principal",
      "security",
      "senior staff",
      "site reliability",
      "software",
      "sre",
      "staff",
      "tooling",
    ]
  end

  def self.leadership_keywords
    [
      "cto",
      "director of cloud",
      "director of devops",
      "director of engineering",
      "director of infrastructure",
      "director of platform",
      "director of sre",
      "engineering director",
      "head of devops",
      "head of engineering",
      "head of infrastructure",
      "head of platform",
      "head of sre",
      "vp cloud",
      "vp devops",
      "vp engineering",
      "vp infrastructure",
      "vp of engineering",
      "vp platform",
      "vp sre"
    ]
  end
end