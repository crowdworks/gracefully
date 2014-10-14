module Gracefully
  class DegradableCommand
    def initialize(args)
      @usually = args[:usually]
      @fallback_to = args[:fallback_to]
    end

    def call(*args)
      Try.to { @usually.call *args }.
        or_else(Try.to { @fallback_to.call *args }).
        get
    end
  end
end
