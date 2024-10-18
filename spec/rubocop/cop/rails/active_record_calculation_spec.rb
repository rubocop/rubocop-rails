# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActiveRecordCalculation, :config do
  it 'registers an offense and corrects when using `pluck.max`' do
    expect_offense(<<~RUBY)
      Model.pluck(:column).max
            ^^^^^^^^^^^^^^^^^^ Use `maximum` instead of `pluck.max`.
    RUBY

    expect_correction(<<~RUBY)
      Model.maximum(:column)
    RUBY
  end

  it 'registers an offense and corrects when using `pluck.min`' do
    expect_offense(<<~RUBY)
      Model.pluck(:column).min
            ^^^^^^^^^^^^^^^^^^ Use `minimum` instead of `pluck.min`.
    RUBY

    expect_correction(<<~RUBY)
      Model.minimum(:column)
    RUBY
  end

  it 'registers an offense and corrects when using `pluck.sum`' do
    expect_offense(<<~RUBY)
      Model.pluck(:column).sum
            ^^^^^^^^^^^^^^^^^^ Use `sum` instead of `pluck.sum`.
    RUBY

    expect_correction(<<~RUBY)
      Model.sum(:column)
    RUBY
  end

  it 'registers an offense and corrects when using `pluck.max` without receiver' do
    expect_offense(<<~RUBY)
      pluck(:column).max
      ^^^^^^^^^^^^^^^^^^ Use `maximum` instead of `pluck.max`.
    RUBY

    expect_correction(<<~RUBY)
      maximum(:column)
    RUBY
  end

  it 'registers an offense and corrects when using `pluck.max` with non-literal column' do
    expect_offense(<<~RUBY)
      Model.pluck(column).max
            ^^^^^^^^^^^^^^^^^ Use `maximum` instead of `pluck.max`.
    RUBY

    expect_correction(<<~RUBY)
      Model.maximum(column)
    RUBY
  end

  it 'does not register an offense when using `pluck.max` with multiple arguments' do
    expect_no_offenses(<<~RUBY)
      Model.pluck(:column1, :column2).max
    RUBY
  end

  it 'does not register an offense when using `pluck.max` with block' do
    expect_no_offenses(<<~RUBY)
      Model.pluck(:column).max { |e| e }
    RUBY
  end

  it 'does not register an offense when using `pluck.max` and `max` has argument' do
    expect_no_offenses(<<~RUBY)
      Model.pluck(:column).max(1)
    RUBY
  end

  it 'does not register an offense when using `maximum`' do
    expect_no_offenses(<<~RUBY)
      Model.maximum(:column)
    RUBY
  end
end
