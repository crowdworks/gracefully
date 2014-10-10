require "gracefully/version"
require "gracefully/feature"
require "gracefully/feature_builder"
require "gracefully/try"

module Gracefully
  def self.degrade(feature_name)
    FeatureBuilder.new(feature_name)
  end

  def self.command(*args, &block)
    callable, options = Command.normalize_arguments(*args, &block)

    if options[:timeout]
      command(TimedCommand.new(callable, options), options.dup.tap { |h| h.delete(:timeout) })
    elsif options[:retries]
      command(RetriedCommand.new(callable, options), options.dup.tap { |h| h.delete(:retries) })
    elsif options[:allowed_failures]
      ShortCircuitedCommand.new(callable, options)
    end
  end
end
