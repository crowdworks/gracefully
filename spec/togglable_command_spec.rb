require 'gracefully/togglable_command'

RSpec.describe Gracefully::TogglableCommand do
  subject {
    described_class.new(run_only_if: -> { current_user == target_user }) { |a| a + ' modified' }.call arg
  }

  let(:arg) {
    'input'
  }

  let(:current_user) {
    'mikoto'
  }

  context 'when the `run_only_if` block returns true' do
    let(:target_user) {
      'mikoto'
    }

    it { is_expected.to eq('input modified') }
  end

  context 'when the `run_only_if` block returns false' do
    let(:target_user) {
      'kuroko'
    }

    specify { expect { subject }.to raise_error(Gracefully::CommandDisabledError) }
  end
end
