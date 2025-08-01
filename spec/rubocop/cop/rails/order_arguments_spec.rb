# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::OrderArguments, :config do
  it 'registers an offense for `order` with a string argument' do
    expect_offense(<<~RUBY)
      User.order('first_name')
                 ^^^^^^^^^^^^ Prefer `:first_name` instead.
    RUBY

    expect_correction(<<~RUBY)
      User.order(:first_name)
    RUBY
  end

  it 'registers an offense for `order` with multiple string arguments' do
    expect_offense(<<~RUBY)
      User.order('first_name', 'last_name')
                 ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `:first_name, :last_name` instead.
    RUBY

    expect_correction(<<~RUBY)
      User.order(:first_name, :last_name)
    RUBY
  end

  it 'registers an offense for `order` with a string argument with DESC direction' do
    expect_offense(<<~RUBY)
      User.order('name DESC')
                 ^^^^^^^^^^^ Prefer `name: :desc` instead.
    RUBY

    expect_correction(<<~RUBY)
      User.order(name: :desc)
    RUBY
  end

  it 'registers an offense for `order` with a string argument with ASC order' do
    expect_offense(<<~RUBY)
      User.order('name ASC')
                 ^^^^^^^^^^ Prefer `:name` instead.
    RUBY

    expect_correction(<<~RUBY)
      User.order(:name)
    RUBY
  end

  it 'registers an offense for `order` with DESC column followed by implicit ASC column' do
    expect_offense(<<~RUBY)
      User.order('first_name DESC, last_name')
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `first_name: :desc, last_name: :asc` instead.
    RUBY

    expect_correction(<<~RUBY)
      User.order(first_name: :desc, last_name: :asc)
    RUBY
  end

  it 'registers an offense for `order` with explicit ASC column followed by implicit ASC column' do
    expect_offense(<<~RUBY)
      User.order('first_name ASC, last_name')
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `:first_name, :last_name` instead.
    RUBY

    expect_correction(<<~RUBY)
      User.order(:first_name, :last_name)
    RUBY
  end

  it 'registers an offense for safe navigation `order` with a string argument' do
    expect_offense(<<~RUBY)
      User&.order('first_name')
                  ^^^^^^^^^^^^ Prefer `:first_name` instead.
    RUBY

    expect_correction(<<~RUBY)
      User&.order(:first_name)
    RUBY
  end

  it 'registers an offense for `order` with multiple string arguments, one of which has multiple sorts' do
    expect_offense(<<~RUBY)
      User.order('first_name, middle_name', 'last_name')
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `:first_name, :middle_name, :last_name` instead.
    RUBY

    expect_correction(<<~RUBY)
      User.order(:first_name, :middle_name, :last_name)
    RUBY
  end

  it 'registers an offense for `order` with lowercase direction' do
    expect_offense(<<~RUBY)
      User.order('name desc')
                 ^^^^^^^^^^^ Prefer `name: :desc` instead.
    RUBY

    expect_correction(<<~RUBY)
      User.order(name: :desc)
    RUBY
  end

  it 'registers an offense for `order` with uppercase column' do
    expect_offense(<<~RUBY)
      User.order('NAME DESC')
                 ^^^^^^^^^^^ Prefer `name: :desc` instead.
    RUBY

    expect_correction(<<~RUBY)
      User.order(name: :desc)
    RUBY
  end

  it 'does not register an offense for `order` with symbol argument' do
    expect_no_offenses(<<~RUBY)
      User.order(:first_name)
    RUBY
  end

  it 'does not register an offense for `order` with a string and a symbol argument' do
    expect_no_offenses(<<~RUBY)
      User.order(:first_name, 'last_name')
    RUBY
  end

  it 'does not register an offense for `order` with string argument expression' do
    expect_no_offenses(<<~RUBY)
      User.order('LEFT(first_name, 1)')
    RUBY
  end
end
