# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authorize/version'

Gem::Specification.new do |spec|
  spec.name          = "authorize"
  spec.version       = Authorize::VERSION
  spec.authors       = ["NASDAQ Private Market Engineering Team"]
  spec.email         = ["developers@npm.com"]
  spec.summary       = "A simple resource authorization library for rack/rails apps."
  spec.description   = "Authorize resources using reusable strategies"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "interactor"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "actionpack"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rack-test"
end
