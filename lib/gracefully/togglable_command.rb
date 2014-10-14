require_relative 'command'
require_relative 'command_disabled_error'

module Gracefully
  class TogglableCommand < Command
    def initialize(*args, &block)
      super

      @run_only_if = @options[:run_only_if]
    end

    def call(*args, &block)
      if @run_only_if.call
        @callable.call *args, &block
      else
        raise Gracefully::CommandDisabledError
      end
    end
  end
end
