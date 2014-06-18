RSpec.configure do |config|
  config.before{Authorize::Strategy::Stub.reset}
end

RSpec::Matchers.define :have_authorized do |strategy|
  match do |actual|
    Authorize::Strategy::Stub.has_authorized?(strategy) == true
  end

  failure_message_for_should do |actual|
    "expected to have authorized as #{strategy} but did not"
  end
end
