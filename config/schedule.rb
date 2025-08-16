set :output, "/home/jacob/cron_log.log"
set :environment, 'production'
env :PATH, '/home/jacob/.rbenv/shims:/home/jacob/.rbenv/bin:/usr/local/bin:/usr/bin:/bin'
job_type :sh, "/home/jacob/bin/envwrap bash -lc ':task'"

every 1.minutes do
  sh <<~CMD
    cd /home/jacob/code/replicate && \
    git pull && \
    (bundle check || bundle install) && \
    bundle exec whenever --update-crontab && \
    pkill -f sidekiq || true && \
    nohup bash -lc 'cd /home/jacob/code/replicate && exec bundle exec sidekiq -c 15' >> sidekiq.out 2>&1 &
  CMD
end

every 1.minutes do
  sh "cd /home/jacob/code/replicate && bin/rails runner 'CronTestWorker.perform_async' >> /home/jacob/cron_log.log 2>&1"
end