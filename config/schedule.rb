set :output, "/home/jacob/cron_log.log"
set :environment, "production"
set :job_template, "bash -l -c ':job'"            # login shell => loads your env
env :PATH, "/usr/local/bin:/usr/bin:/bin"

job_type :sh, 'bash -lc ":task"'

every :monday, at: "6:00am" do
  # runner "ColdEmailGenerator.new(min_score: 90).call"
end

every 1.minutes do
  runner "CronTestWorker.perform_async"
end

every 1.minutes do
  sh <<~'CMD'
    cd /home/jacob/code/replicate && \
    git pull && \
    bundle install && \
    bundle exec whenever --update-crontab && \
    pkill -f sidekiq && \
    nohup bundle exec sidekiq -c 15 -e production -L log/sidekiq.log --pidfile tmp/pids/sidekiq.pid >/dev/null 2>&1 &
  CMD
end