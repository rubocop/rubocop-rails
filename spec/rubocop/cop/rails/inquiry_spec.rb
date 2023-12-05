# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Inquiry, :config do
  it 'registers an offense when using `String#inquiry`' do
    expect_offense(<<~RUBY)
      'two'.inquiry
            ^^^^^^^ Prefer Ruby's comparison operators over Active Support's `inquiry`.
    RUBY
  end

  it 'registers an offense when using `String&.inquiry`' do
    expect_offense(<<~RUBY)
      'two'&.inquiry
             ^^^^^^^ Prefer Ruby's comparison operators over Active Support's `inquiry`.
    RUBY
  end

  it 'registers an offense when using `Array#inquiry`' do
    expect_offense(<<~RUBY)
      [foo, bar].inquiry
                 ^^^^^^^ Prefer Ruby's comparison operators over Active Support's `inquiry`.
    RUBY
  end

  it 'does not register an offense when `#inquiry` with no receiver' do
    expect_no_offenses(<<~RUBY)
      inquiry
    RUBY
  end

  it "does not register an offense when `#inquiry`'s receiver is a variable" do
    expect_no_offenses(<<~RUBY)
      foo.inquiry
    RUBY
  end

  it 'does not register an offense when using `#inquiry` with arguments' do
    expect_no_offenses(<<~RUBY)
      'foo'.inquiry(bar)
    RUBY
  end
end
