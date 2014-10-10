module Gracefully
  class Counter

  end

  class SingletonInMemoryCounter
    def self.instance
      @instance ||= InMemoryCounter.new
    end
  end

  class InMemoryCounter < Counter
    def initialize
      @count = 0
    end

    def reset!
      @count = 0
    end

    def increment!
      @count += 1
    end

    def count
      @count
    end
  end
end
