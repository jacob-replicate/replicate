class CacheExperienceScheduler
  def self.call
    Experience.templates.find_each.with_index do |experience, i|
      CacheExperienceWorker.perform_in((i * 30).seconds, experience.id)
    end
  end
end