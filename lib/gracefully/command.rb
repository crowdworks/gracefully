module Gracefully
  class Command
    def initialize(*args, &block)
      @callable, @options = if args.size == 0
                              [block, {}]
                            elsif args.size == 1
                              [block, args.first]
                            elsif args.size == 2
                              args
                            else
                              raise "Invalid number of arguments: #{args.size}"
                            end
    end

    def call(*args, &block)
      @callable.call *args, &block
    end
  end
end
