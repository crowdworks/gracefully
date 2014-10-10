require 'timeout'

require_relative 'command'

module Gracefully
  class TimedCommand < Command
    def initialize(*args, &block)
      super

      @timeout = @options[:timeout]
    end

    def call(*args, &block)
      Timeout.timeout(@timeout) do
        @callable.call *args, &block
      end
    end
  end
end
