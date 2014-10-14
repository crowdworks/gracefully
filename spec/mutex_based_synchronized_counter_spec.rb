require 'gracefully/mutex_based_synchronized_counter'

RSpec.describe Gracefully::MutexBasedSynchronizedCounter do
  subject {
    counter.count
  }

  let(:counter) {
    described_class.new(Gracefully::InMemoryCounter.new)
  }

  before do
    @threads = 10.times.map do
      Thread.abort_on_exception = true
      Thread.start do
        counter.increment!
      end
    end
  end

  specify {
    expect(subject).to be_between(0, 10)
  }

  context 'after all the threads have finished' do
    before do
      @threads.each(&:join)
    end

    it { is_expected.to eq(10) }

    context 'and then reset' do
      before do
        @thread = Thread.start do
          counter.reset!
        end
      end

      it { is_expected.to eq(10).or eq(0) }

      context 'eventually' do
        before do
          @thread.join
        end

        it { is_expected.to eq(0) }
      end
    end
  end
end
