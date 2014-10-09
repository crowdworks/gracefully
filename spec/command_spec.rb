require 'gracefully'
require 'gracefully/command'

RSpec.shared_examples 'a command' do
  let(:input1) {
    'input1'
  }

  context 'when the block given to the command succeeds without any error' do
    let(:usually) {
      -> arg1 { 'usually:arg1:' + arg1 }
    }

    it { is_expected.to eq('usually:arg1:input1') }
  end

  context 'when the usually block fails with an error' do
    let(:usually) {
      -> arg1 { raise 'simulated error' }
    }

    specify { expect { subject }.to raise_error('simulated error') }
  end
end

RSpec.describe Gracefully::Command do
  describe "feature call result" do
    subject {
      described_class.new(&usually).call input1
    }

    it_behaves_like 'a command'
  end
end
