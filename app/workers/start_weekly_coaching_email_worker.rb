class StartWeeklyCoachingEmailWorker
  include Sidekiq::Worker

  def perform(member_id)
  end
end