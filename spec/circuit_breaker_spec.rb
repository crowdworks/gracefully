require 'timecop_helper'

require 'gracefully'
require 'gracefully/circuit_breaker'

RSpec.describe Gracefully::CircuitBreaker do
  subject {
    described_class.new(try_close_after: try_close_period)
  }

  let(:try_close_period) {
    10
  }

  context 'when failed' do
    before do
      subject.mark_success
      subject.mark_failure
    end

    specify { expect(subject.open?).to be_truthy }
    specify { expect(subject.closed?).to be_falsey }
  end

  context 'when succeeded' do
    before do
      subject.mark_failure
      subject.mark_success
    end

    specify { expect(subject.open?).to be_falsey }
    specify { expect(subject.closed?).to be_truthy }
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
