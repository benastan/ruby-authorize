module Authorize
  class Strategy
    class Stub
      def self.stub_resolve
        @strategies = {}
        @resolve = resolve = Authorize::Strategy.method(:resolve)

        Authorize::Strategy.send(:define_singleton_method, :resolve) do |strategy_name|
          strategy = resolve.call(strategy_name)
          Stub.new(strategy_name, strategy) if strategy.respond_to?(:perform)
        end
      end

      def self.unstub_resolve
        Authorize::Strategy.send(:define_singleton_method, :resolve, &@resolve)
      end

      def self.strategies
        @strategies
      end

      def self.new(strategy_name, strategy)
        instance = super(strategy_name, strategy)
        self.strategies[strategy_name] = instance
        instance
      end

      def self.has_performed?(strategy_name)
        strategy = @strategies[strategy_name]
        strategy && strategy.has_performed?
      end

      def self.has_authorized?(strategy_name)
        strategy = @strategies[strategy_name]
        strategy && strategy.has_performed? && strategy.success?
      end

      def self.has_failed?(strategy_name)
        strategy = @strategies[strategy_name]
        strategy && strategy.has_performed? && ! strategy.success?
      end

      def self.reset
        @strategies && @strategies.values.each(&:reset)
      end

      def initialize(strategy_name, strategy)
        @strategy_name = strategy_name
        @strategy = strategy
      end

      def perform(context = {})
        @context = context
        @result = @strategy.perform(context)
      end

      def has_performed?
        ! @result.nil?
      end

      def success?
        @result && @result.success?
      end

      def reset
        @result = nil
        @context = nil
      end
    end
  end
end
