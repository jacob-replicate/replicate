class ColdEmailGenerator
  MAX_PER_HOUR            = 4
  DEFAULT_PER_INBOX_RANGE = (20..30)
  SEND_HOURS              = (9..17) # server time

  def initialize(min_score:)
    return unless should_run_today?

    @min_score          = min_score
    @inboxes            = INBOXES.dup
    @targets_for_inbox  = per_inbox_targets
    @contacts           = fetch_contacts(total_message_limit)
    @sent_total         = 0
    @inbox_send_counts  = Hash.new { |h, k| h[k] = 0 }
    @per_hour           = Hash.new { |h, email| h[email] = Hash.new { |x, hour_key| x[hour_key] = 0 } }
  end

  def call
    return if @contacts.empty?

    @contacts.each do |contact|
      break if @sent_total >= total_message_limit

      unless contact.passed_bounce_check?
        contact.update_columns(email: nil, score: -1)
        next
      end

      slot_time = next_valid_slot
      next unless slot_time

      inbox = pick_inbox_for(slot_time)
      next unless inbox
      next unless reserve(contact.id, slot_time)

      message = ColdEmailVariants.build(inbox: inbox, contact: contact)
      SendColdEmailWorker.perform_in([slot_time - Time.now, 5].max, contact.id, message[:subject], message[:body_html], inbox)

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
    holidays = Holidays.on(Date.parse"September 1, 2025").select { |x| x[:regions].include?(:us) }
    (1..4).cover?(Date.today.wday) && holidays.empty?
  end

  def next_valid_slot
    SEND_HOURS.map do |h|
      Time.now.change(hour: h, min: rand(0..59), sec: rand(0..59))
    end.find { |t| t > Time.now && any_inbox_has_capacity?(t) }
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

  def fetch_contacts(limit)
    Contact.where(contacted: false, unsubscribed: [false, nil])
           .where.not(email: nil)
           .where("score >= ?", @min_score)
           .limit((limit * 1.5).ceil)
           .first(limit)
  end

  def per_inbox_targets
    counts = @inboxes.map { rand(DEFAULT_PER_INBOX_RANGE) }
    @inboxes.map.with_index { |inbox, i| [inbox[:email], counts[i]] }.to_h
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
end