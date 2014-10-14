require 'gracefully/degradable'

RSpec.describe Gracefully::Degradable do
  describe 'an object included the Gracefully module' do
    subject {
      klass.new
    }

    context 'with the first method constantly failing' do
      let(:klass) {
        Class.new do
          include Gracefully::Degradable

          def foo
            raise 'simulated error'
          end

          def bar
            "bar"
          end

          gracefully_degrade :foo, fallback: [:bar]
        end
      }

      specify { expect(subject.foo).to eq('bar') }
    end

    context 'with the first method timing out' do
      let(:klass) {
        Class.new do
          include Gracefully::Degradable

          def foo
            sleep 1
          end

          def baz
            "baz"
          end

          gracefully_degrade :foo, timeout: 0.1, fallback: [:baz]
        end
      }

      specify { expect(subject.foo).to eq('baz') }
    end
  end
end
