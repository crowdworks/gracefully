module Gracefully
  class Feature
    def initialize(args)
      @name = args[:name]
      @usually = args[:usually]
      @fallback_to = args[:fallback_to]
    end

    def call(*args)
      Try.to { @usually.call *args }.or_else(Try.to { @fallback_to.call *args }).get
    end
  end
end
