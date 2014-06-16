require 'spec_helper'

describe Authorize::Controller do
  include Rack::Test::Methods

  let(:application){Class.new(Rails::Engine)}

  def app; application; end

  def controller; last_request.env['action_controller.instance']; end

  def make_controller(&block)
    controller = Class.new(ActionController::Base) do
      include Authorize::Controller

      def show
        render text: 'hello'
      end
    end

    controller.instance_exec(&block) if block_given?

    controller
  end

  before do
    ENV['RAILS_ENV'] = 'test'

    application.routes.draw do
      resources :posts
      resources :toasts
      resources :boasts
      resources :loaves
    end

    Authorize.stub(scope: Proc.new{{jostle: 'popusa'}})

    stub_const('Authorize::User', make_authorization{context[:marshmallow] = 'delicious'})
    stub_const('Authorize::Cruisers', make_authorization{fail!; context[:marshmallow] = 'delicious'})
    stub_const('Authorize::Loaves', make_authorization{context[:bees] = "We'll see who brings in more honey!"})
    stub_const('PostsController', make_controller)
    stub_const('ToastsController', make_controller{authorize :user})
    stub_const('LoavesController', make_controller{authorize(:user); authorize(:loaves)})
    stub_const('BoastsController', make_controller{authorize :cruisers})
  end

  context 'when authorization is not performed' do
    it 'raises AuthorizationNotPerformed' do
      expect(->{get('/posts/1')}).to raise_error Authorize::Controller::AuthorizationNotPerformed
    end
  end

  context 'when authorization is performed, and it is successful' do
    it 'is okay' do
      expect(get('/toasts/1')).to be_ok
    end

    it 'includes context added by the ability' do
      get('/toasts/1')
      expect(controller.authorized_context.marshmallow).to eq 'delicious'
    end

    it 'includes context from the application scope' do
      get('/toasts/1')
      expect(controller.authorized_context.jostle).to eq 'popusa'    
    end

    it 'includes uses context mutations from all calls to .authorize' do
      get('/loaves/1')
      expect(controller.authorized_context.marshmallow).to eq 'delicious'
      expect(controller.authorized_context.bees).to eq "We'll see who brings in more honey!"
    end
  end

  context 'when authorization is performed, and it is not successful' do
    it 'raises AccessDenied' do
      expect(->{get('/boasts/1')}).to raise_error Authorize::Controller::AccessDenied
    end

    it 'does not define controller.authorized_context' do
      get('/boasts/1') rescue
      expect(controller.respond_to?(:authorized_context)).not_to be
    end
  end
end
