module Gracefully
  class Try
    def self.to(&block)
      Unresolved.new(&block)
    end
  end

  class Unresolved
    def initialize(&block)
      @block = block
    end

    def resolve
      @resolved = begin
        Success.with @block.call
      rescue => e
        Failure.with Error.new('Nested error', nested: e)
      end
    end

    def or_else(other)
      resolve.or_else other
    end

    def get
      resolve.get
    end
  end

  class Success
    def self.with(result)
      new result
    end

    def initialize(result)
      @result = result
    end

    def or_else(other)
      self
    end

    def get
      @result
    end
  end

  class Failure
    def self.with(error)
      new error
    end

    def initialize(error)
      @error = error
    end

    def or_else(other)
      other
    end

    def get
      raise @error
    end
  end

  # Thanks to [nested](https://github.com/skorks/nesty) for the original code
  module NestedError
    def initialize(message, args)
      @nested = args[:nested]
      super(message)
    end

    def set_backtrace(backtrace)
      @raw_backtrace = backtrace
      if nested
        backtrace = backtrace - nested_raw_backtrace
        backtrace += ["#{nested.backtrace.first}: #{nested.message} (#{nested.class.name})"]
        backtrace += nested.backtrace[1..-1] || []
      end
      super(backtrace)
    end

    private

    def nested_raw_backtrace
      nested.respond_to?(:raw_backtrace) ? nested.raw_backtrace : nested.backtrace
    end

    def nested
      @nested
    end
  end

  class Error < StandardError
    include NestedError
  end
end
