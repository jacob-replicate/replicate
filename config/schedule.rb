set :output, "/home/jacob/cron_log.log"

every :monday, at: "6:00am" do
  # runner "ColdEmailGenerator.new(min_score: 90).call"
end

every 1.minutes do
  runner "CronTestWorker.perform_async"
end

every 1.minutes do
  sh <<~'CMD'
    source /home/jacob/.bashrc
    cd /home/jacob/code/replicate
    git pull
    bundle install
    bundle exec whenever --update-crontab
    pkill -f sidekiq
    nohup bundle exec sidekiq -c 15 -e production -L log/sidekiq.log --pidfile tmp/pids/sidekiq.pid >/dev/null 2>&1 &
  CMD
end