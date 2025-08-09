class ColdEmailGenerator
  MAX_PER_HOUR            = 4
  DEFAULT_PER_INBOX_RANGE = (20..30)

  def initialize(min_score:, daily_limit: nil)
    return unless should_run_today?

    @min_score          = min_score
    @inboxes            = inboxes
    @targets_for_inbox  = per_inbox_targets(daily_limit) # { email => target_count }
    @contacts           = fetch_contacts(total_message_limit)
    @sent_total         = 0
    @inbox_send_counts  = Hash.new { |h, k| h[k] = 0 }
    @per_hour           = Hash.new { |h, inbox_email| h[inbox_email] = Hash.new { |x, hour_key| x[hour_key] = 0 } }
  end

  def call
    return if @contacts.empty?

    @contacts.each do |contact|
      break if @sent_total >= total_message_limit

      unless contact.passed_bounce_check?
        contact.update_columns(email: nil, score: -1)
        next
      end

      slot_time = next_valid_slot(contact)
      next unless slot_time

      inbox = pick_inbox_for(slot_time)
      next unless inbox
      next unless reserve(contact.id, slot_time)

      message = ColdEmailVariants.build(inbox: inbox, contact: contact)

      SendColdEmailWorker.perform_in(
        [slot_time - Time.now, 5].max,
        contact.id,
        message[:subject],
        message[:body_html],
        inbox.merge(job_key: job_id_for(contact))
      )

      @per_hour[inbox[:email]][hour_key(slot_time)] += 1
      @inbox_send_counts[inbox[:email]] += 1
      contact.update_columns(contacted: true, contacted_at: Time.current)
      @sent_total += 1
    end
  end

  private

  def total_message_limit
    @targets_for_inbox.values.sum
  end

  def should_run_today?
    (1..4).cover?(Date.today.wday) && Holidays.on(Date.today, :us).empty?
  end

  def next_valid_slot(contact)
    allowed_times_today(contact).find { |t| t > Time.now && any_inbox_has_capacity?(t) }
  end

  def pick_inbox_for(time)
    eligible = @inboxes.select do |inbox|
      @inbox_send_counts[inbox[:email]] < @targets_for_inbox[inbox[:email]] &&
        @per_hour[inbox[:email]][hour_key(time)] < MAX_PER_HOUR
    end
    eligible.min_by { |inbox| @inbox_send_counts[inbox[:email]] }
  end

  def any_inbox_has_capacity?(time)
    @inboxes.any? do |inbox|
      @inbox_send_counts[inbox[:email]] < @targets_for_inbox[inbox[:email]] &&
        @per_hour[inbox[:email]][hour_key(time)] < MAX_PER_HOUR
    end
  end

  def allowed_times_today(contact)
    tz   = contact.timezone.to_s
    zone = ActiveSupport::TimeZone[tz] || ActiveSupport::TimeZone["America/New_York"]
    now  = Time.now
    (9..17).map do |h_local|
      local = zone.local(now.year, now.month, now.day, h_local, rand(0..59), rand(0..59))
      Time.at(local.to_i)
    end
  end

  def fetch_contacts(limit)
    Contact.where(contacted: false, unsubscribed: [false, nil])
           .where.not(email: nil)
           .where("score >= ?", @min_score)
           .limit((limit * 1.5).ceil)
           .to_a
           .sort_by { |c| timezone_sort_key(c) }
           .first(limit)
  end

  def timezone_sort_key(contact)
    tz = ActiveSupport::TimeZone[contact.timezone.to_s]
    tz ? tz.utc_offset : 0
  end

  def per_inbox_targets(daily_limit)
    # If daily_limit provided, split evenly; otherwise use per-inbox message_target if present, else random 20–30.
    if daily_limit
      total = daily_limit.to_i
      base  = total / @inboxes.size
      extra = total % @inboxes.size
      counts = @inboxes.each_index.map { |i| base + (i < extra ? 1 : 0) }
    else
      counts = @inboxes.map { |ibox| ibox[:message_target] || rand(DEFAULT_PER_INBOX_RANGE) }
    end
    @inboxes.map.with_index { |ibox, i| [ibox[:email], counts[i]] }.to_h
  end

  def hour_key(time)
    time.utc.strftime("%Y%m%d%H")
  end

  def reserve(contact_id, send_time)
    key = "send:#{send_time.to_date}:#{contact_id}"
    Sidekiq.redis { |r| r.set(key, 1, nx: true, ex: 172_800) }
  end

  def job_id_for(contact)
    "jid:#{contact.id}:#{Date.current}"
  end

  def inboxes
    [
      {
        email:         "jc@try-replicate.info",
        from_name:     "J.C. (Replicate)",
        signature:     "Best,<br/>J.C.",
        json_key_path: "/path/to/jc.json",
        message_target: nil # use default random 20–30 unless you set an integer here
      },
      {
        email:         "jacob@try-replicate.info",
        from_name:     "Jacob C.",
        signature:     "-- Jacob",
        json_key_path: "/path/to/jacob.json",
        message_target: nil
      },
      {
        email:         "jake@try-replicate.info",
        from_name:     "Jake from Replicate",
        signature:     "All the best,<br/>Jake",
        json_key_path: "/path/to/jake.json",
        message_target: nil
      },
      {
        email:         "comer@try-replicate.info",
        from_name:     "J. Comer",
        signature:     "Appreciate ya!",
        json_key_path: "/path/to/comer.json",
        message_target: nil
      }
    ]
  end
end