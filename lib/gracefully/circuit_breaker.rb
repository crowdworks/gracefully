module Gracefully
  class CircuitBreaker
    attr_reader :opened_date

    def initialize(*args)
      if args.size > 0
        options = args.first

        @try_close_after = options[:try_close_after]
      end

      @closed = true
    end

    def execute(&block)
      if open? && (@try_close_after.nil? || try_close_period_passed?.!)
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

    def close!
      @closed = true
    end

    def open!
      @closed = false
      @opened_date = Time.now
    end

    private

    def clear_opened_date!
      @opened_date = nil
    end

    class CurrentlyOpenError < StandardError

    end
  end
end
