module Gracefully
  class DegradableCommand
    def initialize(args)
      @usually = args[:usually]
      @fallback_to = args[:fallback_to]
    end

    def call(*args, &block)
      Try.to { @usually.call *args, &block }.
        or_else(Try.to { @fallback_to.call *args, &block }).
        get
    end
  end
end
