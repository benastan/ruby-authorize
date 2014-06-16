module Authorize
  class Strategy
    extend ActiveSupport::Inflector

    def self.build_strategy(strategy_options)
      strategy_class, strategy_options = 
        if strategy_options.is_a?(Array)
          [ And, strategy_options ]
        else
          [ Or, strategy_options[:either] ]
        end

      strategies = strategy_options.collect{|strategy| resolve(strategy)}
      strategy = build_strategy_organizer(strategy_class)
      strategy.organize(strategies)

      strategy
    end

    def self.build_strategy_organizer(organizer_class)
      organizer = Class.new
      organizer.send(:include, organizer_class)
      organizer
    end

    def self.find_strategy(strategy_name)
      if registry.key?(strategy_name)
        resolve(registry[strategy_name])
      else
        constantize(camelize("authorize/#{strategy_name}"))
      end
    end

    def self.register(strategy_name, strategy)
      registry[strategy_name] = strategy
    end

    def self.registry
      @registry ||= {}
    end

    def self.reset!
      @registry = {}
    end

    def self.resolve(strategy)
      if strategy.is_a?(Symbol)
        find_strategy(strategy)
      elsif strategy.is_a?(Array) || (strategy.is_a?(Hash) && strategy.key?(:either))
        build_strategy(strategy)
      elsif strategy.respond_to?(:perform)
        strategy
      end
    end
  end
end