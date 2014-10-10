require 'gracefully/consecutive_failures_based_health'

RSpec.shared_examples 'healthy' do
  it { is_expected.to be_healthy }
  it { is_expected.not_to be_unhealthy }
end

RSpec.shared_examples 'unhealthy' do
  it { is_expected.to be_unhealthy }
  it { is_expected.not_to be_healthy }
end

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

  context 'initially' do
    it_behaves_like 'healthy'
  end

  context 'after failures less than or equal to the threshold' do
    before do
      less_than_or_equal_to(threshold).times { subject.mark_failure }
    end

    it_behaves_like 'healthy'
  end

  context 'after failures more than the threshold' do
    before do
      more_than(threshold).times { subject.mark_failure }
    end

    it_behaves_like 'unhealthy'
  end

  context 'after failures more than threshold and a success' do
    before do
      more_than(threshold).times { subject.mark_failure }
      subject.mark_success
    end

    it_behaves_like 'healthy'
  end

  context 'after failurse more than thoreshold + 1 and a success' do
    before do
      more_than(threshold + 1).times { subject.mark_failure }
      subject.mark_success
    end

    it_behaves_like 'healthy'
  end

  context 'after consecutive successes' do
    before do
      2.times { subject.mark_success }
    end

    it_behaves_like 'healthy'
  end
end
