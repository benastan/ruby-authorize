require 'bundler'
Bundler.require
require 'authorize'
require 'rails'
require 'rack/test'
require 'action_controller'

module SpecHelpers
  def make_authorization(&block)
    authorization = Class.new{include Interactor}
    authorization.send(:define_method, :perform, &block)
    authorization
  end
end

RSpec.configure do |config|
  config.include(SpecHelpers)
  config.after(:each){Authorize::Strategy.reset!}
end
