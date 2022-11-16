# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DurationArithmetic, :config do
  it 'registers an offense and corrects Time.zone.now instances' do
    expect_offense(<<~RUBY)
      Time.zone.now - 1.second
      ^^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.zone.now - 2.seconds
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.zone.now + 1.second
      ^^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.zone.now + 2.seconds
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
    RUBY

    expect_correction(<<~RUBY)
      1.second.ago
      2.seconds.ago
      1.second.from_now
      2.seconds.from_now
    RUBY
  end

  it 'registers an offense and corrects all duration arithmetic methods' do
    expect_offense(<<~RUBY)
      Time.current - 1.second
      ^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current - 2.seconds
      ^^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 1.second
      ^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 2.seconds
      ^^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 1.minute
      ^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 2.minutes
      ^^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 1.hour
      ^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 2.hours
      ^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 1.day
      ^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 2.days
      ^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 1.week
      ^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 2.weeks
      ^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 1.fortnight
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 2.fortnights
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 1.month
      ^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 2.months
      ^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 1.year
      ^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 2.years
      ^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
    RUBY

    expect_correction(<<~RUBY)
      1.second.ago
      2.seconds.ago
      1.second.from_now
      2.seconds.from_now
      1.minute.from_now
      2.minutes.from_now
      1.hour.from_now
      2.hours.from_now
      1.day.from_now
      2.days.from_now
      1.week.from_now
      2.weeks.from_now
      1.fortnight.from_now
      2.fortnights.from_now
      1.month.from_now
      2.months.from_now
      1.year.from_now
      2.years.from_now
    RUBY
  end

  it 'does not register an offense for two duration operands' do
    expect_no_offenses(<<~RUBY)
      3.days - 1.hour
      3.days + 1.hour
    RUBY
  end

  it 'does not register an offense if the left operand is non current time' do
    expect_no_offenses(<<~RUBY)
      5.hours + Time.current # will raise
      Date.yesterday + 3.days
      created_at - 1.minute
    RUBY
  end

  it 'does not register an offense for `Foo::Time.current`' do
    expect_no_offenses(<<~RUBY)
      Foo::Time.current + 1.hour
    RUBY
  end

  it 'registers and correct an offense for `::Time.current`' do
    expect_offense(<<~RUBY)
      ::Time.current + 1.hour
      ^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
    RUBY

    expect_correction(<<~RUBY)
      1.hour.from_now
    RUBY
  end

  it 'registers and correct an offense for `::Time.zone.now`' do
    expect_offense(<<~RUBY)
      ::Time.zone.now + 1.hour
      ^^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
    RUBY

    expect_correction(<<~RUBY)
      1.hour.from_now
    RUBY
  end
end
