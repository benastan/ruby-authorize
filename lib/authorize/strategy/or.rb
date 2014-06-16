module Authorize::Strategy::Or
  def self.included(included_class)
    included_class.send(:include, Interactor::Organizer)
    included_class.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def perform
      succeeded = interactors.inject(false) do |succeeded, interactor|
        begin
          instance = interactor.perform(context)
        rescue
          rollback
          raise
        end
  
        if succeeded || ! failure?
          true
        else
          context.instance_variable_set(:@failure, false)
          performed << instance
          nil
        end
      end

      context.instance_variable_set(:@failure, succeeded != true)
    end
  end
end
