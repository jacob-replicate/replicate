class ColdEmailGenerator
  MAX_PER_HOUR = 3
  SEND_HOURS = (9..17).to_a
  MAX_MESSAGES_PER_DAY = SEND_HOURS.size * MAX_PER_HOUR

  def initialize(min_score:)
    return unless should_run_today? || Rails.env.development?

    @min_score = min_score
    @inboxes = INBOXES.dup
    @contacts = fetch_contacts
    @per_hour  = Hash.new { |h, email| h[email] = Hash.new { |x, hour| x[hour] = [] } }
    @send_times = build_send_times
    @contact_index = 0
  end

  def call
    return if @contacts.empty?

    @send_times.each_with_index do |send_time, i|
      inbox = @inboxes.shuffle.find { |inbox| inbox_has_room?(inbox["email"], send_time.hour) }
      next unless inbox

      contact = fetch_next_contact!
      break unless contact.present?

      # SendColdEmailWorker.perform_at(send_time, contact.id, inbox)
      @per_hour[inbox["email"]][send_time.hour] << [send_time, contact.id]
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
    Contact.us.enriched.where(contacted: false).where("score >= ?", @min_score).order(score: :desc).limit(200).to_a
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
      iterations = per_inbox * @inboxes.size
      spacing = 60 / iterations

      iterations.times do |i|
        base_minute = (i * spacing).floor
        minute = base_minute + rand(0...spacing)
        second = rand(0..59)
        send_times << start_time.change(hour: hour, min: minute, sec: second)
      end
    end

    send_times.sort
  end
end