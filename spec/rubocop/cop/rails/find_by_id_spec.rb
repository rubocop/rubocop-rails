# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::FindById, :config do
  it 'registers an offense and corrects when using `where(id: ...).take!`' do
    expect_offense(<<~RUBY)
      User.where(id: 1).take!
           ^^^^^^^^^^^^^^^^^^ Use `find(1)` instead of `where(id: 1).take!`.
    RUBY

    expect_correction(<<~RUBY)
      User.find(1)
    RUBY
  end

  it 'registers an offense and corrects when using `where(id: ...)&.take!`' do
    expect_offense(<<~RUBY)
      User.where(id: 1)&.take!
           ^^^^^^^^^^^^^^^^^^^ Use `find(1)` instead of `where(id: 1)&.take!`.
    RUBY

    expect_correction(<<~RUBY)
      User.find(1)
    RUBY
  end

  it 'registers an offense and corrects when using `where(id: ...)&.take!` with safe navigation' do
    expect_offense(<<~RUBY)
      User&.where(id: 1)&.take!
            ^^^^^^^^^^^^^^^^^^^ Use `find(1)` instead of `where(id: 1)&.take!`.
    RUBY

    expect_correction(<<~RUBY)
      User&.find(1)
    RUBY
  end

  it 'registers an offense and corrects when using `find_by_id!`' do
    expect_offense(<<~RUBY)
      User.find_by_id!(1)
           ^^^^^^^^^^^^^^ Use `find(1)` instead of `find_by_id!(1)`.
    RUBY

    expect_correction(<<~RUBY)
      User.find(1)
    RUBY
  end

  it 'registers an offense and corrects when using `find_by_id!` with safe navigation' do
    expect_offense(<<~RUBY)
      User&.find_by_id!(1)
            ^^^^^^^^^^^^^^ Use `find(1)` instead of `find_by_id!(1)`.
    RUBY

    expect_correction(<<~RUBY)
      User&.find(1)
    RUBY
  end

  it 'registers an offense and corrects when using `find_by!(id: ...)`' do
    expect_offense(<<~RUBY)
      User.find_by!(id: 1)
           ^^^^^^^^^^^^^^^ Use `find(1)` instead of `find_by!(id: 1)`.
    RUBY

    expect_correction(<<~RUBY)
      User.find(1)
    RUBY
  end

  it 'registers an offense and corrects when using `find_by!(id: ...)` with safe navigation' do
    expect_offense(<<~RUBY)
      User&.find_by!(id: 1)
            ^^^^^^^^^^^^^^^ Use `find(1)` instead of `find_by!(id: 1)`.
    RUBY

    expect_correction(<<~RUBY)
      User&.find(1)
    RUBY
  end

  it 'does not register an offense when using `find`' do
    expect_no_offenses(<<~RUBY)
      User.find(1)
    RUBY
  end
end
