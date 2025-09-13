class ColdEmailScheduler
  MAX_PER_HOUR = 3
  SEND_HOURS = (9..17).to_a
  MAX_MESSAGES_PER_DAY = SEND_HOURS.size * MAX_PER_HOUR

  def initialize(min_score:)
    return unless should_run_today? || Rails.env.development?

    @min_score = min_score
    @contacts = fetch_contacts
    @per_hour  = Hash.new { |h, email| h[email] = Hash.new { |x, hour| x[hour] = [] } }
    @send_times = build_send_times
    @contact_index = 0
  end

  def call
    return if @contacts.empty?

    @send_times.each_with_index do |send_time, i|
      inbox = INBOXES.dup.shuffle.find { |inbox| inbox_has_room?(inbox["email"], send_time.hour) }
      next unless inbox

      contact = fetch_next_contact!
      break unless contact.present?

      variant = ColdEmailVariants.build(inbox: inbox, contact: contact)
      SendColdEmailWorker.perform_at(send_time, contact.id, inbox, variant)
      contact.update_columns(email_queued_at: Time.now)
      @per_hour[inbox["email"]][send_time.hour] << [inbox["from_name"], inbox["email"], send_time, contact.id, contact.name, contact.email, variant]
    end

    @per_hour
  end

  private

  def inbox_has_room?(email, hour)
    (@per_hour[email].values.sum(&:size) < MAX_MESSAGES_PER_DAY) && (@per_hour[email][hour].size < MAX_PER_HOUR)
  end

  def should_run_today?
    holiday = Holidays.on(Date.today).select { |x| x[:regions].include?(:us) }.any?
    (1..5).cover?(Date.today.wday) && !(holiday)
  end

  def fetch_contacts
    contacts = Contact.us.enriched.where(email_queued_at: nil, contacted_at: nil).where("score >= ?", @min_score).order(score: :desc).limit(200).to_a

    contacts.select do |contact|
      Contact.where("contacted_at > ?", 30.days.ago).where(company_domain: contact.company_domain).blank?
    end
  end

  def fetch_next_contact!
    contact = nil

    while @contact_index < @contacts.length && contact.nil?
      contact = @contacts[@contact_index]
      @contact_index += 1

      return contact if contact.passed_bounce_check?
      contact.update_columns(email: nil, score: contact.score * -1)
    end
  end

  def build_send_times
    send_times = []
    start_time = Time.find_zone("America/New_York").now.beginning_of_day

    SEND_HOURS.each do |hour|
      per_inbox = 3 + rand(0..1)
      iterations = per_inbox * INBOXES.size
      spacing = 60 / iterations

      iterations.times do |i|
        base_minute = (i * spacing).floor
        minute = base_minute + rand(0..spacing)
        second = rand(0..59)
        minute = 59 if minute == 60
        send_times << start_time.change(hour: hour, min: minute, sec: second)
      end
    end

    send_times.sort
  end
end