require "gracefully/version"
require "gracefully/feature"
require "gracefully/feature_builder"
require "gracefully/try"

module Gracefully
  def self.degrade(feature_name)
    FeatureBuilder.new(feature_name)
  end
end
