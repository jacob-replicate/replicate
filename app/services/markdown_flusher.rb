# frozen_string_literal: true

class MarkdownFlusher
  # Flush every 200 ms *or* when a structural boundary is reached
  FLUSH_INTERVAL  = 0.20
  SIZE_HARD_LIMIT = 1_000  # never keep >1 KB unflushed – safety valve

  def initialize(&on_flush)
    @buf         = +""
    @last_flush  = Time.now
    @open_inline = nil      # :bold, :code, :link, or nil
    @on_flush    = on_flush # -> (string) { … }
  end

  # feed each incoming chunk here
  def <<(chunk)
    @buf << chunk
    track_inline_state(chunk)
    flush! if flushable?
    self
  end

  # ensure everything is sent at the end
  def final_flush!
    flush!(force: true)
  end

  private

  # ------- flushing logic -----------------------------------------------

  def flushable?
    return true if Time.now - @last_flush >= FLUSH_INTERVAL
    return true if paragraph_boundary?
    return true if @buf.size >= SIZE_HARD_LIMIT
    false
  end

  def paragraph_boundary?
    # 1) blank line   2) end-of-sentence & no open inline element
    @buf.end_with?("\n\n") ||
      (@buf[-2..] =~ /[.!?]/ && @open_inline.nil?)
  end

  def flush!(force: false)
    return if @buf.empty?
    return unless force || paragraph_boundary? || Time.now - @last_flush >= FLUSH_INTERVAL

    @on_flush.call(@buf.dup)
    @buf.clear
    @last_flush = Time.now
  end

  # ------- inline-state tracker -----------------------------------------

  def track_inline_state(chunk)
    chunk.each_char do |ch|
      case ch
      when '*'
        toggle(:bold)
      when '`'
        toggle(:code)
      when '['
        @open_inline = :link unless @open_inline
      when ']'
        @open_inline = nil if @open_inline == :link
      when ')'
        # close link only if "](...)" pattern was completed – cheap check
        @open_inline = nil if @open_inline == :link
      end
    end
  end

  def toggle(type)
    @open_inline = (@open_inline == type ? nil : type)
  end
end