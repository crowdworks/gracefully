require 'timeout'

module Gracefully
  class TimedCommand
    def initialize(*args, &block)
      @callable, options = if args.size == 1
                             [block, args.first]
                           elsif args.size == 2
                             args
                           else
                             raise "Invalid number of arguments: #{args.size}"
                           end

      @timeout = options[:timeout]
    end

    def call(*args, &block)
      Timeout.timeout(@timeout) do
        @callable.call *args, &block
      end
    end
  end
end
