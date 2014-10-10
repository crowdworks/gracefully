require_relative 'command'
require_relative 'circuit_breaker'
require_relative 'consecutive_failures_based_health'

module Gracefully
  class ShortCircuitedCommand < Command
    def initialize(*args, &block)
      super

      @circuit_breaker = Gracefully::CircuitBreaker.new(
        try_close_after: @options[:try_close_after],
        health: Gracefully::ConsecutiveFailuresBasedHealth.new(
          become_unhealthy_after_consecutive_failures: @options[:allowed_failures],
          counter: @options[:counter]
        )
      )
    end

    def call(*args, &block)
      @circuit_breaker.execute { super }
    end
  end
end
