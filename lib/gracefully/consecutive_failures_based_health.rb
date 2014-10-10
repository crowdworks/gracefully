require_relative 'health'
require_relative 'counter'

module Gracefully
  class ConsecutiveFailuresBasedHealth < Health
    # @param [Hash] args
    def initialize(args)
      @healthy_count = 0
      @unhealthy_count = 0
      conf = Configuration.new(args)
      super(state: Healthy.new(conf))
    end

    class Configuration
      attr_reader :become_unhealthy_after_consecutive_failures

      def initialize(args)
        @become_unhealthy_after_consecutive_failures = args[:become_unhealthy_after_consecutive_failures]
        @counter = args[:counter] || -> { SingletonInMemoryCounter.instance }
      end

      def counter
        @counter.call
      end
    end

    class Health < Gracefully::Health::State
    end

    class Healthy < State
      # @param [Configuration] conf
      def initialize(conf)
        @failure_counter = conf.counter
        @configuration = conf
      end

      def mark_success
        self
      end

      def mark_failure
        @failure_counter.increment!
        if @failure_counter.count <= @configuration.become_unhealthy_after_consecutive_failures
          self
        else
          @failure_counter.reset!
          Unhealthy.new @configuration
        end
      end

      def healthy?
        true
      end
    end

    class Unhealthy < State
      # @param [Configuration] conf
      def initialize(conf)
        @configuration = conf
      end

      def mark_success
        Healthy.new @configuration
      end

      def mark_failure
        self
      end

      def healthy?
        false
      end
    end
  end
end
