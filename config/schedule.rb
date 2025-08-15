set :output, "/home/jacob/cron_log.log"

every :monday, at: "6:00am" do
  # runner "ColdEmailGenerator.new(min_score: 90).call"
end

every 30.minutes do
  command <<~CMD
    cd /home/jacob/replicate && \
    git pull && \
    bundle install && \
    whenever --update-crontab && \
    pkill -f sidekiq || true && \
    bundle exec sidekiq -c 15 -d -L log/sidekiq.log -P tmp/pids/sidekiq.pid -e production
  CMD
end