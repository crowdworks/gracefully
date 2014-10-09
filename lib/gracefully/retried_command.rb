module Gracefully
  class RetriedCommand
    def initialize(*args, &block)
      @callable, options = if args.size == 1
                             [block, args.first]
                           elsif args.size == 2
                             args
                           else
                             raise "Invalid number of arguments: #{args.size}"
                           end

      @retries = options[:retries]
    end

    def call(*args, &block)
      num_tried = 0
      begin
        @callable.call *args, &block
      rescue => e
        num_tried += 1
        if num_tried <= @retries
          retry
        else
          raise Gracefully::Error.new(e.message, nested: e)
        end
      end
    end
  end
end
