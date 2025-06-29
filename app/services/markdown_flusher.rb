class MarkdownFlusher
  FLUSH_INTERVAL = 0.20 # seconds

  def initialize(&on_flush)
    @buf        = +""
    @last_flush = Time.now
    @on_flush   = on_flush # -> (string) { … }
  end

  # Feed each token / chunk here
  def <<(chunk)
    @buf << chunk
    flush! if flush_ready?
    self
  end

  def final_flush!
    flush!(force: true)
  end

  private

  # ----- flushing -------------------------------------------------------
  def flush_ready?
    boundary_reached? || timer_expired?
  end

  def boundary_reached?
    # We treat a blank line as a natural paragraph/list boundary.
    @buf.include?("\n\n")
  end

  def timer_expired?
    Time.now - @last_flush >= FLUSH_INTERVAL
  end

  def flush!(force: false)
    return if @buf.empty?

    chunks = if force
      [@buf]
    else
      # Split on the *last* double‑newline so we keep an unfinished
      # paragraph in @buf for the next round.
      head, sep, tail = @buf.rpartition(/\n\n/)
      sep.empty? ? [] : [head + sep]
    end

    chunks.each { |c| @on_flush.call(c) }
    @buf.sub!(chunks.join, "")
    @last_flush = Time.now
  end
end