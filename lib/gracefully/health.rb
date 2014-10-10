module Gracefully
  class Health
    def initialize(args)
      @state = args[:state]
    end

    def mark_success
      @state = @state.mark_success
    end

    def mark_failure
      @state = @state.mark_failure
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
  end
end
