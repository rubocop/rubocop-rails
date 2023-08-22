# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TimeUnitNumberForm, :config do
  it 'registers an offense when using incorrect singulars' do
    expect_offense(<<~RUBY)
      1.years
        ^^^^^ Use `year`.
      1.months
        ^^^^^^ Use `month`.
      1.weeks
        ^^^^^ Use `week`.
      1.days
        ^^^^ Use `day`.
      1.hours
        ^^^^^ Use `hour`.
      1.minutes
        ^^^^^^^ Use `minute`.
      1.seconds
        ^^^^^^^ Use `second`.
    RUBY

    expect_correction(<<~RUBY)
      1.year
      1.month
      1.week
      1.day
      1.hour
      1.minute
      1.second
    RUBY
  end

  it 'registers an offense when using incorrect plural form' do
    expect_offense(<<~RUBY)
      0.year
        ^^^^ Use `years`.
      0.month
        ^^^^^ Use `months`.
      0.week
        ^^^^ Use `weeks`.
      0.day
        ^^^ Use `days`.
      0.hour
        ^^^^ Use `hours`.
      0.minute
        ^^^^^^ Use `minutes`.
      0.second
        ^^^^^^ Use `seconds`.
    RUBY

    expect_correction(<<~RUBY)
      0.years
      0.months
      0.weeks
      0.days
      0.hours
      0.minutes
      0.seconds
    RUBY
  end

  it 'does not register an offense when using correct singular form' do
    expect_no_offenses(<<~RUBY)
      1.hour
    RUBY
  end

  it 'does not register an offense when using correct plural form' do
    expect_no_offenses(<<~RUBY)
      0.hours
    RUBY
  end

  it 'does not register an offense when receiver is a variable' do
    expect_no_offenses(<<~RUBY)
      var.hour
      var.hours
    RUBY
  end
end
