set :output, "/home/jacob/cron_log.log"
set :environment, 'production'
env :PATH, '/home/jacob/.rbenv/shims:/home/jacob/.rbenv/bin:/usr/local/bin:/usr/bin:/bin'
job_type :sh, "/home/jacob/bin/envwrap bash -lc ':task'"

every 1.minutes do
  sh <<~CMD
    cd /home/jacob/code/replicate && \
    git pull && \
    (bundle check || bundle install) && \
    bundle exec whenever --update-crontab
  CMD
end

every :saturday, at: '2:10pm' do
  sh "cd /home/jacob && touch cron_test_scheduled.txt"
end

every 1.minutes do
  sh "cd /home/jacob/code/replicate && bin/rails runner 'CronTestWorker.perform_async' >> /home/jacob/cron_log.log 2>&1"
end