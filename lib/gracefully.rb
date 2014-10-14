require "gracefully/version"
require "gracefully/degradable_command"
require "gracefully/degradable_command_builder"
require "gracefully/try"

module Gracefully
  def self.degradable_command(*args, &block)
    DegradableCommandBuilder.new.usually(*args, &block)
  end

  def self.command(*args, &block)
    callable, options = Command.normalize_arguments(*args, &block)

    if options[:timeout]
      command(TimedCommand.new(callable, options), options.dup.tap { |h| h.delete(:timeout) })
    elsif options[:retries]
      command(RetriedCommand.new(callable, options), options.dup.tap { |h| h.delete(:retries) })
    elsif options[:allowed_failures]
      command(ShortCircuitedCommand.new(callable, options), options.dup.tap { |h| h.delete(:allowed_failures) })
    elsif options[:run_only_if]
      TogglableCommand.new(callable, options)
    else
      Command.new(callable, options)
    end
  end
end
