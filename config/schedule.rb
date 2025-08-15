set :output, "/home/jacob/cron_log.log"

every :monday, at: "6:00am" do
  # runner "ColdEmailGenerator.new(min_score: 90).call"
end

every 1.minutes do
  runner "CronTestWorker.perform_async"
end

every 30.minutes do
  command "bash -lc 'source /home/jacob/.bashrc'"
  command "bash -lc 'cd /home/jacob/code/replicate'"
  command "bash -lc 'git pull'"
  command "bash -lc 'bundle install'"
  command "bash -lc 'bundle exec whenever --update-crontab'"
  command "bash -lc 'pkill -f sidekiq || true'"
  command "bash -lc 'nohup bundle exec sidekiq -c 15 -e production -L log/sidekiq.log --pidfile tmp/pids/sidekiq.pid'"
end