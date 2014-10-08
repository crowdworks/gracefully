module Gracefully
  class Command
    def initialize(&block)
      @block = block
    end

    def call(*args, &block)
      @block.call *args, &block
    end
  end
end
