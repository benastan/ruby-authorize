require "interactor"
require "active_support"
require "authorize/version"
require "authorize/controller"
require "authorize/strategy"
require "authorize/strategy/and"
require "authorize/strategy/or"

module Authorize
  cattr_accessor :scope
end
