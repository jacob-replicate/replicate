set :output, "/home/jacob/cron_log.log"

every :monday, at: "6:00am" do
  # runner "ColdEmailGenerator.new(min_score: 90).call"
end

every 1.minutes do
  runner "CronTestWorker.perform_async"
end

every 30.minutes do
  command <<~CMD
    cd /home/jacob/replicate &&
    git pull &&
    sudo -n bundle install &&
    sudo bundle exec whenever --update-crontab &&
    sudo pkill -f sidekiq || true &&
    sudo bundle exec sidekiq -c 15 -d -L log/sidekiq.log -P tmp/pids/sidekiq.pid -e production
  CMD
end