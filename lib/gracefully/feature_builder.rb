module Gracefully
  class FeatureBuilder
    def initialize(feature_name)
      @feature_name = feature_name
    end

    def usually(*args, &block)
      @usually = Gracefully.command(*args, &block)
      self
    end

    def fallback_to(*args, &block)
      @fallback_to = Gracefully.command(*args, &block)

      build
    end

    private

    def build
      Feature.new(name: @feature_name, usually: @usually, fallback_to: @fallback_to)
    end
  end
end
