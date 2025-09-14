set :output, "/home/jacob/cron_log.log"
set :environment, 'production'
env :PATH, '/home/jacob/.rbenv/shims:/home/jacob/.rbenv/bin:/usr/local/bin:/usr/bin:/bin'
job_type :sh, "/home/jacob/bin/envwrap bash -lc ':task'"

every 1.hour do
  sh <<~CMD
    cd /home/jacob/code/replicate && \
    git pull && \
    (sudo bundle check || sudo bundle install) && \
    bundle exec whenever --update-crontab
  CMD
end

every :weekday, at: '6:00am' do
  sh "cd /home/jacob/code/replicate && bin/rails runner 'EnrichContactScheduler.call' >> /home/jacob/cron_log.log 2>&1"
end

every :weekday, at: '7:00am' do
  # sh "cd /home/jacob/code/replicate && bin/rails runner 'ColdEmailScheduler.new(min_score: 90).call' >> /home/jacob/cron_log.log 2>&1"
end

every 1.minutes do
  # sh "cd /home/jacob/code/replicate && bin/rails runner 'CronTestWorkerV2.perform_async' >> /home/jacob/cron_log.log 2>&1"
end