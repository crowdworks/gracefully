require 'timecop_helper'

require 'gracefully'
require 'gracefully/circuit_breaker'

RSpec.shared_examples 'a open circuit breaker' do
  specify { expect(subject.open?).to be_truthy }
  specify { expect(subject.closed?).to be_falsey }
end

RSpec.shared_examples 'a closed circuit breaker' do
  specify { expect(subject.open?).to be_falsey }
  specify { expect(subject.closed?).to be_truthy }
end

RSpec.shared_examples 'a circuit breaker' do
  context 'when failed' do
    before do
      subject.mark_success
      subject.mark_failure
    end

    it_behaves_like 'a open circuit breaker'
  end

  context 'when succeeded' do
    before do
      subject.mark_failure
      subject.mark_success
    end

    it_behaves_like 'a closed circuit breaker'
  end

  context 'when opened' do
    before do
      subject.open!
    end

    it_behaves_like 'a open circuit breaker'
  end

  context 'when closed' do
    before do
      subject.close!
    end

    it_behaves_like 'a closed circuit breaker'
  end
end

RSpec.describe Gracefully::CircuitBreaker do
  context 'without try_close_period' do
    subject {
      described_class.new
    }

    it_behaves_like 'a circuit breaker'
  end

  context 'with try_close_period' do
    subject {
      described_class.new(try_close_after: try_close_period)
    }

    let(:try_close_period) {
      10
    }

    it_behaves_like 'a circuit breaker'

    it 'passes the integration test' do
      initial_failure_time = Time.now

      Timecop.freeze(initial_failure_time) do
        expect {
          subject.execute do
            raise 'foo'
          end
        }.to raise_error('foo')

        expect(subject.open?).to be_truthy
        expect(subject.closed?).to be_falsey
        expect(subject.opened_date).not_to be_nil
      end

      Timecop.freeze(initial_failure_time + 10) do
        expect {
          subject.execute do
          end
        }.to raise_error(Gracefully::CircuitBreaker::CurrentlyOpenError)

        expect(subject.open?).to be_truthy
        expect(subject.closed?).to be_falsey
        expect(subject.opened_date).not_to be_nil
      end

      Timecop.freeze(initial_failure_time + 11) do
        expect(
          subject.execute do
            'baz'
          end
        ).to eq('baz')

        expect(subject.open?).to be_falsey
        expect(subject.closed?).to be_truthy
        expect(subject.try_close_period_passed?).to be_falsey
        expect(subject.opened_date).to be_nil
      end
    end

    context 'when try-close period passed after its opened' do
      before do
        Timecop.freeze(failed_date) do
          subject.mark_failure
        end
      end

      let(:failed_date) {
        Time.now
      }

      let(:after_date) {
        failed_date + 11
      }

      specify { expect(subject.open?).to be_truthy }
      specify { expect(subject.closed?).to be_falsey }
      specify { expect(subject.opened_date).to eq(failed_date) }
      specify {
        Timecop.freeze(after_date) do
          expect(subject.try_close_period_passed?).to be_truthy
        end
      }
      specify {
        Timecop.freeze(failed_date) do
          expect(subject.try_close_period_passed?).to be_falsey
        end
      }
    end
  end
end
