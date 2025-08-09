class ColdEmailGenerator
  MAX_PER_HOUR            = 4
  DEFAULT_PER_INBOX_RANGE = (20..30)
  SEND_HOURS              = (9..17).to_a

  def initialize(min_score:)
    return unless should_run_today?

    @min_score         = min_score
    @inboxes           = INBOXES.dup
    @targets_for_inbox = @inboxes.map.with_index { |inbox, i| [inbox[:email], rand(DEFAULT_PER_INBOX_RANGE)] }.to_h
    @contacts          = fetch_contacts
    @per_hour  = Hash.new { |h, email| h[email] = Hash.new { |x, hour| x[hour] = 0 } }
    @day_slots = build_day_slots
  end

  def call
    return if @contacts.empty?

    @contacts.each do |contact|
      break if total_sends_so_far >= total_message_limit

      unless contact.passed_bounce_check?
        contact.update_columns(email: nil, score: -1)
        next
      end

      slot_time, inbox = next_slot_and_inbox
      break unless slot_time

      message = ColdEmailVariants.build(inbox: inbox, contact: contact)
      SendColdEmailWorker.perform_in([slot_time - Time.now, 5].max, contact.id, message[:subject], message[:body_html], inbox)
      @per_hour[inbox[:email]][hour_key(slot_time)] += 1
      contact.update_columns(contacted: true, contacted_at: Time.current)
    end
  end

  private

  def inbox_total_sent(email)
    @per_hour[email].values.sum
  end

  def total_sends_so_far
    @per_hour.values.sum { |h| h.values.sum }
  end

  def inbox_has_daily_room?(email)
    inbox_total_sent(email) < @targets_for_inbox[email]
  end

  def inbox_has_hour_room?(email, hour)
    @per_hour[email][hour] < MAX_PER_HOUR
  end

  def total_message_limit
    @targets_for_inbox.values.sum
  end

  def should_run_today?
    (1..4).cover?(Date.today.wday) && Holidays.on(Date.today, :us).empty?
  end

  def fetch_contacts
    limit = (total_message_limit * 1.5).ceil
    Contact.where(contacted: false, unsubscribed: [false, nil]).where.not(email: nil).where("score >= ?", @min_score).limit(limit).to_a
  end

  def build_day_slots
    now = Time.now
    SEND_HOURS.map { |h| now.change(hour: h, min: rand(0..59), sec: rand(0..59)) }.sort
  end

  def next_slot_and_inbox
    @day_slots.each_with_index do |t, idx|
      hour = hour_key(t)
      eligible = @inboxes.select { |inbox| inbox_has_daily_room?(inbox[:email]) && inbox_has_hour_room?(inbox[:email], hour) }
      next if eligible.empty?

      inbox = eligible.min_by { |inbox| inbox_total_sent(inbox[:email]) }
      @day_slots.delete_at(idx)
      return [t, inbox]
    end

    nil
  end

  def hour_key(time)
    time.utc.strftime("%Y%m%d%H")
  end
end