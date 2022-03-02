# frozen_string_literal: true

RSpec.describe RuboCop::Rails::Inject do
  describe '#defaults!' do
    before { allow(Dir).to receive(:pwd).and_return('/home/foo/project') }

    it 'makes excludes absolute' do
      configuration = described_class.defaults!
      expect(configuration['AllCops']['Exclude'])
        .to include(
          '/home/foo/project/bin/*',
          '/home/foo/project/db/*schema.rb'
        )
    end
  end
end
