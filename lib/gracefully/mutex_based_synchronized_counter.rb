require_relative 'counter'

require 'thread'

module Gracefully
  # The counter equipped with the possibly easiest kind of synchronization.
  class MutexBasedSynchronizedCounter < Counter
    # @param [Counter] counter
    def initialize(counter)
      @counter = counter
      @mutex = Mutex.new
    end

    def reset!
      @mutex.synchronize do
        @counter.reset!
      end
    end

    def increment!
      @mutex.synchronize do
        @counter.increment!
      end
    end

    def count
      @counter.count
    end
  end
end
