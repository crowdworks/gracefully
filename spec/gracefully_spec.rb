require 'gracefully'

RSpec.shared_context 'successful fallback' do
  let(:fallback_to) {
    -> arg1 { 'fallback:arg1:' + arg1 }
  }
end

RSpec.shared_context 'failing fallback' do
  let(:fallback_to) {
    -> arg1 { raise 'simulated error of fallback' }
  }
end

RSpec.describe Gracefully do
  describe "feature call result" do
    subject {
      Gracefully.
        degrade(feature_name).
        usually(&usually).
        fallback_to(&fallback_to).
        call input1
    }

    let(:input1) {
      'input1'
    }

    context 'when the feature is defined for the name' do
      let(:feature_name) {
        :the_feature
      }

      include_context 'successful fallback'

      context 'when the usually block succeeds without any error' do
        let(:usually) {
          -> arg1 { 'usually:arg1:' + arg1 }
        }

        it { is_expected.to eq('usually:arg1:input1') }
      end

      context 'when the usually block fails with an error' do
        let(:usually) {
          -> arg1 { raise 'simulated error' }
        }

        it { is_expected.to eq('fallback:arg1:input1') }
      end
    end

    context 'when both the usual block and the fallback block fail' do
      let(:feature_name) {
        :the_feature
      }

      include_context 'failing fallback'

      let(:usually) {
        -> arg1 { raise 'simulated error' }
      }

      specify { expect { subject }.to raise_error(/Tried to get the value of a failure/) }
    end
  end

  describe 'the command' do
    let(:allowed_failures) { 1 }

    let (:command) {
      described_class.command(
        timeout: 0.1,
        retries: 1,
        allowed_failures: allowed_failures,
        run_only_if: run_only_if,
        counter: -> { Gracefully::InMemoryCounter.new },
        &body
      )
    }

    subject {
      command.call
    }

    context 'which is enabled' do
      let(:run_only_if) {
        -> { true }
      }

      context 'which is successful' do
        let(:body) {
          -> { 'ok' }
        }

        it { is_expected.to eq('ok') }
      end

      context 'which fails at first and then succeeds' do
        let(:body) {
          count = 0
          -> {
            count += 1
            if count == 1
              raise 'simulated error'
            else
              'ok'
            end
          }
        }

        it { is_expected.to eq('ok') }
      end

      context 'which is failing' do
        let(:body) {
          -> { raise 'simulated error' }
        }

        context 'after failures more than allowed' do
          before do
            (allowed_failures + 1).times do
              expect { subject }.to raise_error(Gracefully::Error, 'simulated error')
            end
          end

          specify {
            expect { subject }.to raise_error(Gracefully::CircuitBreaker::CurrentlyOpenError)
          }
        end
      end

      context 'which is timing out' do
        let(:body) {
          -> { sleep 1 }
        }

        specify {
          expect { subject }.to raise_error(Gracefully::Error, 'execution expired')
        }

        context 'after failures more than allowed' do
          before do
            (allowed_failures + 1).times do
              expect { subject }.to raise_error(Gracefully::Error, 'execution expired')
            end
          end

          specify {
            expect { subject }.to raise_error(Gracefully::CircuitBreaker::CurrentlyOpenError)
          }
        end
      end
    end

    context 'which is disabled' do
      let(:run_only_if) {
        -> { false }
      }

      let(:body) {
        -> { 'ok' }
      }

      specify {
        expect { subject }.to raise_error(Gracefully::CommandDisabledError)
      }
    end
  end
end
