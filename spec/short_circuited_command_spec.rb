require 'gracefully'
require 'gracefully/short_circuited_command'

RSpec.shared_examples "a short-circuited command" do
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

    context 'more than allowed times' do
      let(:failed_at) {
        Time.now
      }

      before do
        Timecop.freeze(failed_at) do
          2.times do
            expect { subject }.to raise_error('simulated error')
          end
        end
      end

      around do |ex|
        Timecop.freeze(failed_at + passed_seconds) { ex.run }
      end

      context '0 seconds passed' do
        let(:passed_seconds) { 0 }

        specify {
          expect { subject }.to raise_error(Gracefully::CircuitBreaker::CurrentlyOpenError)
        }
      end

      context 'try_close_after seconds passed' do
        let(:passed_seconds) { try_close_after }

        specify {
          expect { subject }.to raise_error(Gracefully::CircuitBreaker::CurrentlyOpenError)
        }
      end

      context 'try_close_after + 1 seconds passed' do
        let(:passed_seconds) { try_close_after + 1 }

        specify {
          expect { subject }.to raise_error('simulated error')
        }
      end
    end
  end
end

RSpec.describe Gracefully::ShortCircuitedCommand do
  context "command creation with invalid number of arguments" do
    subject {
      described_class.new(1, 2, 3)
    }

    specify { expect { subject }.to raise_error(/Invalid number of arguments: 3/) }
  end

  let(:try_close_after) {
    3
  }

  describe 'with 0 allowed failures' do
    context 'made of a callable object' do
      subject {
        described_class.new(usually, allowed_failures: 0).call input1
      }

      it_behaves_like 'a command'
    end
  end

  describe "with more than 1 allowed failures" do
    subject {
      command.call input1
    }

    let(:allowed_failures) {
      1
    }

    let(:options) {
      {
        allowed_failures: allowed_failures,
        try_close_after: try_close_after,
        counter: -> { Gracefully::InMemoryCounter.new }
      }
    }

    context 'made of a callable object' do
      let(:command) {
        described_class.new(usually, options)
      }

      it_behaves_like 'a short-circuited command'
    end

    context 'made of a command' do
      let(:command) {
        described_class.new(callable, options)
      }

      it_behaves_like 'a short-circuited command'
    end

    context 'made of a block' do
      let(:command) {
        described_class.new(options, &usually)
      }

      it_behaves_like 'a short-circuited command'
    end
  end
end
