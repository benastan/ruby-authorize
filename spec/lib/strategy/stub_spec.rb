require 'authorize/strategy/stub'
require 'spec_helper'

module Authorize
  class Strategy
    describe Stub do
      let(:strategy) do
        make_authorization{context[:marshmallow] = 'delicious'}
      end

      before{stub_const('Authorize::User', strategy)}

      describe '.stub_resolve/.unstub_resolve' do
        it 'stubs' do
          Stub.stub_resolve
          expect(Strategy.resolve(:user)).to be_a(Stub)
          Stub.unstub_resolve
        end
        
        it 'unstubs' do
          Stub.stub_resolve
          Stub.unstub_resolve
          expect(Strategy.resolve(:user)).to eq strategy
        end
      end

      describe '.new/#initialize' do
        around do |example|
          Stub.stub_resolve
          example.run
          Stub.unstub_resolve
        end

        subject {Authorize::Strategy.resolve(:user)}

        it 'keeps track of all stubs' do
          expect(->{subject}).to change{Stub.strategies[:user]}.from(nil).to(instance_of(Stub))
        end

        it 'wraps the right strategy' do
          Stub.stub(:new).and_call_original
          subject
          Stub.should have_received(:new).with(:user, strategy)
        end
      end

      describe 'class methods' do
        let(:stub){Stub.new(:user, strategy)}
        let(:result){double(success?: success?)}
        let(:success?){true}
        before{strategy.stub(perform: result)}

        context 'when the stub has not been performed' do
          specify{expect(Stub).not_to have_performed(:user)}
          specify{expect(Stub).not_to have_authorized(:user)}
          specify{expect(Stub).not_to have_failed(:user)}
        end

        context 'when the stub has been performed and succeeded' do
          before{stub.perform}
          specify{expect(Stub).to have_performed(:user)}
          specify{expect(Stub).to have_authorized(:user)}
          specify{expect(Stub).not_to have_failed(:user)}
        end

        context 'when the stub has been performed and failed' do
          before{stub.perform}
          let(:success?){false}
          specify{expect(Stub).to have_performed(:user)}
          specify{expect(Stub).not_to have_authorized(:user)}
          specify{expect(Stub).to have_failed(:user)}
          # specify{require 'pry';binding.pry}
        end

        context 'when Stub has been reset' do
          before{stub.perform}
          before{Stub.reset}
          specify{expect(Stub).not_to have_performed(:user)}
          specify{expect(Stub).not_to have_authorized(:user)}
          specify{expect(Stub).not_to have_failed(:user)}
        end
      end

      describe 'instance methods' do
        subject(:stub){Stub.new(:user, strategy)}
        let(:result){double(success?: success?)}
        let(:success?){true}
        
        before do
          strategy.stub(perform: result)
        end

        context 'when it has not performed' do
          specify{expect(stub).not_to have_performed}
          specify{expect(stub).not_to be_success}
          specify{expect(stub.instance_variable_get(:@context)).to be_nil}
          specify{expect(stub.instance_variable_get(:@result)).to be_nil}
        end

        context 'when it has performed and succeeded' do
          before{stub.perform('context')}
          specify{expect(stub).to have_performed}
          specify{expect(stub).to be_success}
          specify{expect(stub.instance_variable_get(:@context)).to eq 'context'}
          specify{expect(stub.instance_variable_get(:@result)).to eq result}
        end

        context 'when it has performed and failed' do
          before{stub.perform('context')}
          let(:success?){false}
          specify{expect(stub).to have_performed}
          specify{expect(stub).not_to be_success}
          specify{expect(stub.instance_variable_get(:@context)).to eq 'context'}
          specify{expect(stub.instance_variable_get(:@result)).to eq result}
        end

        context 'when it has performed and been reset' do
          before{stub.perform('context')}
          before{stub.reset}
          specify{expect(stub).not_to have_performed}
          specify{expect(stub).not_to be_success}
          specify{expect(stub.instance_variable_get(:@context)).to be_nil}
          specify{expect(stub.instance_variable_get(:@result)).to be_nil}
        end
      end
    end
  end
end