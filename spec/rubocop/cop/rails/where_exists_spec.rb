# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::WhereExists do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects when using `where(...).exists?` with hash argument' do
    expect_offense(<<~RUBY)
      User.where(name: 'john').exists?
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `exists?(name: 'john')` over `where(name: 'john').exists?`.
    RUBY

    expect_correction(<<~RUBY)
      User.exists?(name: 'john')
    RUBY
  end

  it 'registers an offense and corrects when using `where(...).exists?` with array argument' do
    expect_offense(<<~RUBY)
      User.where(['name = ?', 'john']).exists?
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `exists?(['name = ?', 'john'])` over `where(['name = ?', 'john']).exists?`.
    RUBY

    expect_correction(<<~RUBY)
      User.exists?(['name = ?', 'john'])
    RUBY
  end

  it 'registers an offense and corrects when using `where(...).exists?` with multiple arguments' do
    expect_offense(<<~RUBY)
      User.where('name = ?', 'john').exists?
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `exists?(['name = ?', 'john'])` over `where('name = ?', 'john').exists?`.
    RUBY

    expect_correction(<<~RUBY)
      User.exists?(['name = ?', 'john'])
    RUBY
  end

  it 'does not register an offense when using `where(...).exists?` with string argument' do
    expect_no_offenses(<<~RUBY)
      User.where("name = 'john'").exists?
    RUBY
  end

  it 'does not register an offense when using `exists?`' do
    expect_no_offenses(<<~RUBY)
      User.exists?(name: 'john')
    RUBY
  end
end
