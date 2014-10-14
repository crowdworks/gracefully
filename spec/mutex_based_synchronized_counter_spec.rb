require 'gracefully/mutex_based_synchronized_counter'

RSpec.describe Gracefully::MutexBasedSynchronizedCounter do
  subject {
    described_class.new(Gracefully::InMemoryCounter.new)
  }

  before do
    @threads = 10.times.map do
      Thread.start do
        subject.increment!
      end
    end
  end

  specify {
    expect(subject.count).to be_between(0, 10)

    @threads.each(&:join)

    expect(subject.count).to eq(10)
  }
end
