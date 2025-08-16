class StartWeeklyCoachingEmailWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(member_id, current_day_start)
    # TODO: Guard clause(s)
    # TODO: Create the conversation
    # TODO: Send it
  end
end