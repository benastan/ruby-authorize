require 'spec_helper'

describe Authorize::Strategy::Or do
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

  let(:strategy) do
    strategy_class = Class.new
    strategy_class.send(:include, Authorize::Strategy::Or)
    strategy_class
  end

  context 'when all succeed' do
    before{strategy.organize([make_succeeding_strategy, make_succeeding_strategy])}
    subject(:result){strategy.perform}
    it{should be_success}
  end

  context 'when one fails' do
    before{strategy.organize([make_failing_strategy, make_succeeding_strategy])}
    subject(:result){strategy.perform}
    it{should be_success}
  end

  context 'when all fails' do
    before{strategy.organize([make_failing_strategy, make_failing_strategy])}
    subject(:result){strategy.perform}
    it{should_not be_success}
  end
end