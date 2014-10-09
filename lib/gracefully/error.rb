module Gracefully
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
