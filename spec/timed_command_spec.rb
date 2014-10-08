require 'gracefully'
require 'gracefully/command'
require 'gracefully/timed_command'

RSpec.shared_examples "a timed command" do
  let(:input1) {
    'input1'
  }

  let(:callable) {
    Gracefully::Command.new(&usually)
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

  context 'when the usually block call takes longer than the time out period' do
    let(:usually) {
      -> arg1 { sleep(0.1) }
    }

    specify { expect { subject }.to raise_error(Timeout::Error) }
  end
end

RSpec.describe Gracefully::TimedCommand do
  describe "feature call result" do
    context 'made of a callable object' do
      subject {
        described_class.new(usually, timeout: 0.01).call input1
      }

      it_behaves_like 'a timed command'
    end

    context 'made of a command' do
      subject {
        described_class.new(callable, timeout: 0.01).call input1
      }

      it_behaves_like 'a timed command'
    end

    context 'made of a block' do
      subject {
        described_class.new(timeout: 0.01, &usually).call input1
      }

      it_behaves_like 'a timed command'
    end
  end
end
