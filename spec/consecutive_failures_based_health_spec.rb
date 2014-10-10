require 'gracefully/consecutive_failures_based_health'

RSpec.describe Gracefully::ConsecutiveFailuresBasedHealth do
  subject {
    described_class.new(
      become_unhealthy_after_consecutive_failures: threshold,
      counter: -> { Gracefully::InMemoryCounter.new }
    )
  }

  let(:threshold) {
    1
  }

  def less_than_or_equal_to(t)
    t
  end

  def more_than(t)
    t + 1
  end

  it { is_expected.to be_healthy }
  it { is_expected.not_to be_unhealthy }

  context 'after failures less than or equal to the threshold' do
    before do
      less_than_or_equal_to(threshold).times { subject.mark_failure }
    end

    it { is_expected.to be_healthy }
    it { is_expected.not_to be_unhealthy }
  end

  context 'after failures more than the threshold' do
    before do
      more_than(threshold).times { subject.mark_failure }
    end

    it { is_expected.to be_unhealthy }
    it { is_expected.not_to be_healthy }
  end

  context 'after failures more than threshold and a success' do
    before do
      more_than(threshold).times { subject.mark_failure }
      subject.mark_success
    end

    it { is_expected.to be_healthy }
    it { is_expected.not_to be_unhealthy }
  end
end