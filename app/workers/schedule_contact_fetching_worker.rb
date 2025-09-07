class ScheduleContactFetchingWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(job_title)
    pagination = FetchContactsWorker.new.perform(job_title, 1, true)
    page_count = Hash(pagination)["total_pages"]
    return if page_count.blank?

    1.upto(page_count) do |page|
      FetchContactsWorker.perform_in((page * 20).seconds, job_title, page)
    end
  end
end