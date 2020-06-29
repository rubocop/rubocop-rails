# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Inquiry do
  subject(:cop) { described_class.new }

  it 'registers an offense when using `#inquiry`' do
    expect_offense(<<~RUBY)
      'two'.inquiry
            ^^^^^^^ Prefer Ruby's comparison operators over Active Support's `inquiry`.
    RUBY
  end

  it 'does not register an offense when using `#inquiry` with arguments' do
    expect_no_offenses(<<~RUBY)
      foo.inquiry(bar)
    RUBY
  end
end
