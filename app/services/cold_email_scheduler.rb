class ColdEmailScheduler
  MAX_PER_HOUR = 3
  SEND_HOURS = (11..14).to_a
  MAX_MESSAGES_PER_DAY = SEND_HOURS.size * MAX_PER_HOUR

  def initialize(min_score:)
    return unless should_run_today? || Rails.env.development?

    @min_score = min_score
    @contacts = fetch_contacts
    @per_hour  = Hash.new
    @send_times = build_send_times
  end

  def call
    return if @contacts.empty?

    @send_times.each_with_index do |send_time, i|
      inbox = INBOXES.dup.shuffle.find { |inbox| inbox_has_room?(inbox["email"], send_time.hour) }
      next unless inbox

      contact = fetch_next_contact!
      break unless contact.present?

      variant = ColdEmailVariants.build(inbox: inbox, contact: contact)
      Rails.logger.info "SendColdEmailWorker: #{contact.name} (#{contact.email}) - #{Time.at(send_time).in_time_zone('America/New_York').strftime("%A, %b %-d - %-l:%M%P (ET)")} - #{inbox['email']} - #{variant}"
      SendColdEmailWorker.perform_at(send_time, contact.id, inbox, variant)
      contact.update_columns(email_queued_at: Time.now)
      email = inbox["email"]
      @per_hour[email] ||= {}
      @per_hour[email][send_time.hour] ||= []
      @per_hour[email][send_time.hour] << [inbox["from_name"], inbox["email"], send_time, contact.id, contact.name, contact.email, variant]
    end

    @per_hour
  end

  private

  def inbox_has_room?(email, hour)
    details = @per_hour[email]
    return true if details.blank?
    (details.values.sum(&:size) < MAX_MESSAGES_PER_DAY) && (details[hour].blank? || details[hour].size < MAX_PER_HOUR)
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

    while (contact = @contacts.shift).present?
      return contact if contact.passed_bounce_check?
      contact.update_columns(email: nil, score: contact.score * -1)
    end

    nil
  end

  def build_send_times
    send_times = []
    start_time = Time.find_zone("America/New_York").now.beginning_of_day

    SEND_HOURS.each do |hour|
      per_inbox = MAX_PER_HOUR
      iterations = per_inbox * INBOXES.size
      spacing = 60 / iterations

      iterations.times do |i|
        base_minute = (i * spacing).floor
        minute = base_minute + rand(0..spacing)
        second = rand(0..59)
        minute = 59 if minute >= 60
        send_times << start_time.change(hour: hour, min: minute, sec: second)
      end
    end

    send_times.sort
  end
end