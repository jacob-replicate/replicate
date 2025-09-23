class EnrichContactScheduler
  def self.call(limit: 100)
    i = 0
    Contact.unenriched.us.where("score >= 90").order(score: :desc).pluck(:id).each_slice(10) do |ids|
      EnrichContactsWorker.perform_in((i * 30).seconds, ids)
      i += 1
      return if i >= (limit / 10)
    end
  end
end