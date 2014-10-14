require 'gracefully'

module Gracefully
  module Degradable
    def self.included(base)
      base.extend(ClassMethods)
    end

    def __call_gracefully_degradable_method__(method, *args, &block)
      self.class.instance_variable_get(:@__gracefully_degradable_methods__)[method].call(self, *args, &block)
    end

    module ClassMethods
      def gracefully_degrade(method, options)
        @__gracefully_degradable_methods__ ||= {}

        fallback_method, fallback_options = options[:fallback].first
        fallback_options ||= {}

        original_method = "#{method}_without_graceful_degradation"

        @__gracefully_degradable_methods__[method] =
          Gracefully.degradable_command(options) { |instance, *args, &block|
            instance.__send__(original_method, *args, &block)
          }.fallback_to(fallback_options) { |instance, *args, &block|
            instance.__send__(fallback_method, *args, &block)
          }

        alias_method original_method, method
        define_method method do |*args, &block|
          __call_gracefully_degradable_method__(method, *args, &block)
        end
      end
    end
  end
end
