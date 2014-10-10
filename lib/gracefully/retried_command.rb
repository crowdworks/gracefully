require_relative 'command'

module Gracefully
  class RetriedCommand < Command
    def initialize(*args, &block)
      super

      @retries = @options[:retries]
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
