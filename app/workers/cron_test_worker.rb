class CronTestWorker
  include Sidekiq::Worker

  def perform(path = "/home/jacob/cron_test.txt")
    File.open(path, "a") do |file|
      file.puts "#{Time.now} - #{Contact.count}"
    end
  end
end