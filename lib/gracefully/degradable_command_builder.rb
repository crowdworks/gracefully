module Gracefully
  class DegradableCommandBuilder
    def initialize
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
      DegradableCommand.new(usually: @usually, fallback_to: @fallback_to)
    end
  end
end
