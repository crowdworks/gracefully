module Gracefully
  class FeatureBuilder
    def initialize(feature_name)
      @feature_name = feature_name
    end

    def usually(&block)
      @usually = block
      self
    end

    def fallback_to(&block)
      @fallback_to = block

      build
    end

    private

    def build
      Feature.new(name: @feature_name, usually: @usually, fallback_to: @fallback_to)
    end
  end
end
