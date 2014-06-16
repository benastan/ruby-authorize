require 'spec_helper'

describe Authorize::Strategy do
  describe '.resolve' do
    context 'when the strategy is a symbol' do
      before{Authorize::Strategy.stub(find_strategy: nil)}
      
      it 'tries to find the strategy' do
        Authorize::Strategy.resolve(:user)
        expect(Authorize::Strategy).to have_received(:find_strategy).with(:user)
      end
    end

    context 'when the strategy is an array' do
      before{Authorize::Strategy.stub(build_strategy: nil)}
      
      it 'tries to find the strategy' do
        Authorize::Strategy.resolve([ :strategy ])
        expect(Authorize::Strategy).to have_received(:build_strategy).with([ :strategy ])
      end
    end

    context 'when the strategy is strategy class' do
      let(:strategy) { double(perform: 'blah') }

      it 'returns the strategy itself' do
        expect(Authorize::Strategy.resolve(strategy)).to eq strategy
      end
    end
  end

  describe '.find_strategy' do
    let(:authorize_user){double(perform: double(success?: true))}

    before{stub_const('Authorize::User', authorize_user)}

    context 'when a strategy is registered' do
      before do
        Authorize::Strategy.stub(resolve: 'found strategy')
        Authorize::Strategy.register(:user, 'registered strategy')
      end

      it 'tries to resolve the strategy from the registry' do
        expect(Authorize::Strategy.find_strategy(:user)).to eq 'found strategy'
        expect(Authorize::Strategy).to have_received(:resolve).with('registered strategy')
      end
    end

    context 'when a strategy is not registered' do
      it 'constantizes the strategy and returns the constant' do
        expect(Authorize::Strategy.find_strategy(:user)).to eq authorize_user
      end
    end
  end

  describe '.build_strategy' do
    let(:authorize_admin){double('authorize_admin', perform: double(success?: true))}
    let(:authorize_user){double('authorize_user', perform: double(success?: true))}
    let(:authorize_cat){double('authorize_cat', perform: double(success?: true))}
    let(:fake_organizer){double(organize: nil)}

    before do
      stub_const('Authorize::User', authorize_user)
      Authorize::Strategy.register(:meow, authorize_cat)
      Authorize::Strategy.stub(build_strategy_organizer: fake_organizer)
    end

    it 'builds the strategy' do
      Authorize::Strategy.build_strategy([ :user, :meow, authorize_admin ])
      expect(fake_organizer).to have_received(:organize).with([authorize_user, authorize_cat, authorize_admin])
    end
  end

  describe '.build_strategy_organizer' do
    before{Class.stub(new: fake_class)}
    let(:fake_class){double(include: nil)}

    it 'creates a new class and includes Interactor::Organizer' do
      expect(Authorize::Strategy.build_strategy_organizer(:organizer_class)).to eq fake_class
      expect(fake_class).to have_received(:include).with(:organizer_class)
    end
  end

  describe '.register' do
    it 'adds the strategy to the registry' do
      expect(Authorize::Strategy.registry).to eq({})
      Authorize::Strategy.register(:foo, :bar)
      expect(Authorize::Strategy.registry).to eq(foo: :bar)
    end
  end

  describe 'integration' do
    def make_failing_strategy
      Class.new do
        include Interactor

        def perform
          fail!
        end
      end
    end
    
    def make_succeeding_strategy
      Class.new do
        include Interactor
        def perform; end
      end
    end

    let(:user_strategy) { make_succeeding_strategy }
    let(:admin_strategy) { make_succeeding_strategy }
    let(:cat_strategy) { make_succeeding_strategy }
    let(:dog_strategy) { make_succeeding_strategy }

    before do
      stub_const('Authorize::User', user_strategy)
      stub_const('Authorize::Admin', admin_strategy)
      stub_const('Authorize::Cat', cat_strategy)
      stub_const('Authorize::Dog', dog_strategy)
    end

    context 'when all are required' do
      subject(:strategy) { Authorize::Strategy.resolve([:user, :admin, :cat]).perform }

      context 'when all succeed' do
        it { should be_success }
      end

      context 'when cat fails' do
        let(:cat_strategy) { make_failing_strategy }
        it { should_not be_success }
      end
    end

    context 'when user is required, but either admin or cat' do
      subject(:strategy) { Authorize::Strategy.resolve([:user, { either: [ [ :dog, :admin ], :cat ] }]).perform }

      context 'when all succeed' do
        it { should be_success }
      end

      context 'when user fails' do
        let(:user_strategy) { make_failing_strategy }
        it { should_not be_success }
      end
      
      context 'when cat fails, but dog and admin succeed' do
        let(:cat_strategy) { make_failing_strategy }
        it { should be_success }
      end
      
      context 'when cat and dog fail, but admin succeeds' do
        let(:cat_strategy) { make_failing_strategy }
        let(:dog_strategy) { make_failing_strategy }
        it { should_not be_success }
      end
      
      context 'when cat and admin fail, but dog succeeds' do
        let(:cat_strategy) { make_failing_strategy }
        let(:admin_strategy) { make_failing_strategy }
        it { should_not be_success }
      end
    end
  end
end
