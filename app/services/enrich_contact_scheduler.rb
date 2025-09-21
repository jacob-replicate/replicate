class EnrichContactScheduler
  def self.call(limit: 100)
    i = 0
    Contact.unenriched.us.where("score >= 90").order(score: :desc).find_in_batches(batch_size: 10) do |batch|
      EnrichContactsWorker.perform_in((i * 30).seconds, batch.map(&:id))
      i += 1
      return if i >= (limit / 10)
    end
  end
end