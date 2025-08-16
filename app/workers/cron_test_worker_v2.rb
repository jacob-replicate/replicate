class CronTestWorkerV2
  include Sidekiq::Worker

  def perform(path = "/home/jacob/cron_new_file_v1.txt")
    File.open(path, "a") do |file|
      file.puts "#{Time.now} - #{Contact.count}"
    end
  end
end