class CronTestWorker
  include Sidekiq::Worker

  def perform(path = "/home/jacob/cron_test_v3.txt")
    File.open(path, "a") do |file|
      file.puts "#{Time.now} - #{Contact.count}"
    end
  end
end