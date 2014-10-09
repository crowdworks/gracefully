require 'gracefully'
require 'gracefully/command'
require 'gracefully/retried_command'

RSpec.shared_examples "a retried command" do
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

  context 'when the usually block fails' do
    let(:usually) {
      num_trials = 0
      -> arg1 {
        num_trials += 1
        if num_trials == 1
          raise 'simulated error'
        else
          'usually:arg1:' + arg1
        end
      }
    }

    specify {
      expect(subject).to eq('usually:arg1:input1')
    }
  end
end

RSpec.describe Gracefully::RetriedCommand do
  context "command creation with invalid number of arguments" do
    subject {
      described_class.new(1, 2, 3)
    }

    specify { expect { subject }.to raise_error(/Invalid number of arguments: 3/) }
  end

  describe 'with 0 retries' do
    context 'made of a callable object' do
      subject {
        described_class.new(usually, retries: 0).call input1
      }

      it_behaves_like 'a command'
    end
  end

  describe "with more than 1 retries" do
    context 'made of a callable object' do
      subject {
        described_class.new(usually, retries: 1).call input1
      }

      it_behaves_like 'a retried command'
    end

    context 'made of a command' do
      subject {
        described_class.new(callable, retries: 1).call input1
      }

      it_behaves_like 'a retried command'
    end

    context 'made of a block' do
      subject {
        described_class.new(retries: 1, &usually).call input1
      }

      it_behaves_like 'a retried command'
    end
  end
end
