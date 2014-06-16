module Authorize::Strategy::And
  def self.included(included_class)
    included_class.send(:include, Interactor::Organizer)
  end
end