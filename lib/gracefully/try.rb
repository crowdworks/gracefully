require_relative 'error'

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
        # Back-traces, which are required by Gracefully::Error, of errors are usually set by `raise`.
        # We need to set them manually because we aren't relying on `raise`.
        Failure.with Error.new('Nested error', nested: e).tap { |e| e.set_backtrace caller(0) }
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
      raise Error.new('Tried to get the value of a failure', nested: @error)
    end
  end
end
