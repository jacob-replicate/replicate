class PopulateExperienceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(experience_id)
    PopulateExperience.new(experience_id).call
  end
end