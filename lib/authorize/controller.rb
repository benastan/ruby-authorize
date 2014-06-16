module Authorize
  module Controller
    class AccessDenied < StandardError; end
    class AuthorizationNotPerformed < StandardError; end

    extend ActiveSupport::Concern

    included do
      prepend_before_filter do
        begin
          raise_error = ! authorization_performed?
        rescue
          raise_error = true
        end

        raise AuthorizationNotPerformed if raise_error
      end

      def authorization_performed?
        @authorization_performed == true
      end

      def self.authorize(*args)
        options = {}

        if args.first.is_a?(Hash) && args.first.key?(:strategy)
          options = args.first
          args = options.delete(:strategy)
        end
        
        strategy = Authorize::Strategy.resolve(args)
        
        prepend_before_filter(options) do
          scope = self.instance_exec(&Authorize.scope).dup
          scope = scope.merge(authorized_context.context.to_hash) if respond_to?(:authorized_context)
          authorized_context = strategy.perform(scope)

          if authorized_context.success?
            define_singleton_method(:authorized_context){authorized_context}
            define_singleton_method(:authorization_performed?){true}
          else
            raise AccessDenied
          end
        end
      end
    end
  end
end
