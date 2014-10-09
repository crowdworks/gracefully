module Gracefully
  class CircuitBreaker
    attr_reader :opened_date

    def initialize(args)
      @try_close_after = args[:try_close_after]
      @closed = true
    end

    def execute(&block)
      if open? && try_close_period_passed?.!
        raise CurrentlyOpenError, "Opened at #{opened_date}"
      end

      clear_opened_date!

      begin
        v = block.call
        mark_success
        v
      rescue => e
        mark_failure
        raise e
      end
    end

    def mark_success
      close!
    end

    def mark_failure
      open!
    end

    def open?
      closed?.!
    end

    def closed?
      @closed
    end

    def try_close_period_passed?
      opened_date && opened_date + @try_close_after < Time.now
    end

    def opened_date
      @opened_date
    end

    private

    def close!
      @closed = true
    end

    def open!
      @closed = false
      @opened_date = Time.now
    end

    def clear_opened_date!
      @opened_date = nil
    end

    class CurrentlyOpenError < StandardError

    end
  end
end
