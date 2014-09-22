module Gracefully
  class HealthMeter
    def initialize(args)
      @healthy_count = 0
      @unhealthy_count = 0
      @state = Healthy.new configuration: args[:configuration]
    end

    def mark_healthy
      @state = @state.mark_healthy
    end

    def mark_unhealthy
      @state = @state.mark_unhealthy
    end

    def healthy?
      @state.healthy?
    end

    def unhealthy?
      @state.unhealthy?
    end

    class State
      def unhealthy?
        !healthy?
      end
    end

    class Configuration
      attr_reader :healthy_threshold, :unhealthy_threshold

      def initialize(args)
        @healthy_threshold = args[:healthy_threshold]
        @unhealthy_threshold = args[:unhealthy_threshold]
      end
    end

    class Healthy < State
      def initialize(args)
        @unhealthy_count = 0
        @configuration = args[:configuration]
      end

      def mark_healthy
        self
      end

      def mark_unhealthy
        @unhealthy_count += 1

        if @unhealthy_count <= @configuration.unhealthy_threshold
          self
        else
          Unhealthy.new configuration: @configuration
        end
      end

      def healthy?
        true
      end
    end

    class Unhealthy < State
      def initialize(args)
        @healthy_count = 0
        @configuration = args[:configuration]
      end

      def mark_healthy
        @healthy_count += 1

        if @healthy_count <= @configuration.healthy_threshold
          self
        else
          Healthy.new configuration: @configuration
        end
      end

      def mark_unhealthy
        self
      end

      def healthy?
        false
      end
    end
  end
end
