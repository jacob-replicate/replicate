class CronTestWorkerV2
  include Sidekiq::Worker

  def perform(path = "/home/jacob/cron_new_env_v2.txt")
    File.open(path, "a") do |file|
      file.puts "#{Time.now} - #{Contact.count} - #{ENV["BOUNCER_API_KEY"]}"
    end
  end
end