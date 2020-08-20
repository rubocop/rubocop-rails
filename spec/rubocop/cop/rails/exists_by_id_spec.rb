# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ExistsById do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects when using `exists?(id: ...)` with integer argument' do
    expect_offense(<<~RUBY)
      User.exists?(id: 1)
           ^^^^^^^^^^^^^^ Prefer `exists?(1)` over `exists?(id: 1)`.
    RUBY

    expect_correction(<<~RUBY)
      User.exists?(1)
    RUBY
  end

  it 'registers an offense and corrects when using `exists?(id: ...)` with string argument' do
    expect_offense(<<~RUBY)
      User.exists?(id: '1')
           ^^^^^^^^^^^^^^^^ Prefer `exists?('1')` over `exists?(id: '1')`.
    RUBY

    expect_correction(<<~RUBY)
      User.exists?('1')
    RUBY
  end

  it 'does not register an offense when using `exists?(...)`' do
    expect_no_offenses(<<~RUBY)
      User.exists?(1)
    RUBY

    expect_no_offenses(<<~RUBY)
      User.exists?('1')
    RUBY
  end

  it 'does not register an offence when using `exists?(id: ...)` with array argument' do
    expect_no_offenses(<<~RUBY)
      User.exists?(id: [1, 2, 3])
    RUBY
  end

  it 'does not register an offence when using `exists?(...)` with multiple argument' do
    expect_no_offenses(<<~RUBY)
      User.exists?(id: 1, email: 'test@example.com')
    RUBY
  end
end
