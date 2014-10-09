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
end
