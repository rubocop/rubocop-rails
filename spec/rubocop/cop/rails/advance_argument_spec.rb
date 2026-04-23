# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::AdvanceArgument, :config do
  # ----------------------------------------------------------------
  # Singular key offenses (autocorrectable)
  # ----------------------------------------------------------------

  it 'registers an offense and corrects `hour:` key' do
    expect_offense(<<~RUBY)
      time.advance(hour: -1)
                   ^^^^ Invalid key `:hour` for `#advance`. Did you mean `hours:`?
    RUBY

    expect_correction(<<~RUBY)
      time.advance(hours: -1)
    RUBY
  end

  it 'registers an offense and corrects `minute:` key' do
    expect_offense(<<~RUBY)
      time.advance(minute: 30)
                   ^^^^^^ Invalid key `:minute` for `#advance`. Did you mean `minutes:`?
    RUBY

    expect_correction(<<~RUBY)
      time.advance(minutes: 30)
    RUBY
  end

  it 'registers an offense and corrects `second:` key' do
    expect_offense(<<~RUBY)
      time.advance(second: 45)
                   ^^^^^^ Invalid key `:second` for `#advance`. Did you mean `seconds:`?
    RUBY

    expect_correction(<<~RUBY)
      time.advance(seconds: 45)
    RUBY
  end

  it 'registers an offense and corrects `day:` key' do
    expect_offense(<<~RUBY)
      date.advance(day: 1)
                   ^^^ Invalid key `:day` for `#advance`. Did you mean `days:`?
    RUBY

    expect_correction(<<~RUBY)
      date.advance(days: 1)
    RUBY
  end

  it 'registers an offense and corrects `week:` key' do
    expect_offense(<<~RUBY)
      date.advance(week: 2)
                   ^^^^ Invalid key `:week` for `#advance`. Did you mean `weeks:`?
    RUBY

    expect_correction(<<~RUBY)
      date.advance(weeks: 2)
    RUBY
  end

  it 'registers an offense and corrects `month:` key' do
    expect_offense(<<~RUBY)
      date.advance(month: 3)
                   ^^^^^ Invalid key `:month` for `#advance`. Did you mean `months:`?
    RUBY

    expect_correction(<<~RUBY)
      date.advance(months: 3)
    RUBY
  end

  it 'registers an offense and corrects `year:` key' do
    expect_offense(<<~RUBY)
      date.advance(year: 2024)
                   ^^^^ Invalid key `:year` for `#advance`. Did you mean `years:`?
    RUBY

    expect_correction(<<~RUBY)
      date.advance(years: 2024)
    RUBY
  end

  it 'registers offenses and corrects multiple singular keys' do
    expect_offense(<<~RUBY)
      date.advance(year: 1, month: 2, day: 3)
                   ^^^^ Invalid key `:year` for `#advance`. Did you mean `years:`?
                            ^^^^^ Invalid key `:month` for `#advance`. Did you mean `months:`?
                                      ^^^ Invalid key `:day` for `#advance`. Did you mean `days:`?
    RUBY

    expect_correction(<<~RUBY)
      date.advance(years: 1, months: 2, days: 3)
    RUBY
  end

  it 'registers an offense and corrects when using hash rocket syntax' do
    expect_offense(<<~RUBY)
      time.advance(:hour => -1)
                   ^^^^^ Invalid key `:hour` for `#advance`. Did you mean `hours:`?
    RUBY

    expect_correction(<<~RUBY)
      time.advance(:hours => -1)
    RUBY
  end

  it 'registers an offense and corrects with safe navigation operator' do
    expect_offense(<<~RUBY)
      time&.advance(hour: -1)
                    ^^^^ Invalid key `:hour` for `#advance`. Did you mean `hours:`?
    RUBY

    expect_correction(<<~RUBY)
      time&.advance(hours: -1)
    RUBY
  end

  it 'registers an offense and corrects on Time.zone.now receiver' do
    expect_offense(<<~RUBY)
      Time.zone.now.advance(hour: -1)
                            ^^^^ Invalid key `:hour` for `#advance`. Did you mean `hours:`?
    RUBY

    expect_correction(<<~RUBY)
      Time.zone.now.advance(hours: -1)
    RUBY
  end

  it 'registers an offense and corrects on Time.current receiver' do
    expect_offense(<<~RUBY)
      Time.current.advance(hour: -1)
                           ^^^^ Invalid key `:hour` for `#advance`. Did you mean `hours:`?
    RUBY

    expect_correction(<<~RUBY)
      Time.current.advance(hours: -1)
    RUBY
  end

  it 'registers offenses for singular keys mixed with valid plural keys' do
    expect_offense(<<~RUBY)
      time.advance(years: 1, hour: -1)
                             ^^^^ Invalid key `:hour` for `#advance`. Did you mean `hours:`?
    RUBY

    expect_correction(<<~RUBY)
      time.advance(years: 1, hours: -1)
    RUBY
  end

  # ----------------------------------------------------------------
  # Date-incompatible time-unit keys (warning only, no autocorrect)
  # ----------------------------------------------------------------

  it 'registers an offense for `hours:` on `Date.today`' do
    expect_offense(<<~RUBY)
      Date.today.advance(hours: 3)
                         ^^^^^ `hours:` is not supported by `Date#advance`. Use `years:`, `months:`, `weeks:`, or `days:` instead.
    RUBY
  end

  it 'registers an offense for `minutes:` on `Date.today`' do
    expect_offense(<<~RUBY)
      Date.today.advance(minutes: 30)
                         ^^^^^^^ `minutes:` is not supported by `Date#advance`. Use `years:`, `months:`, `weeks:`, or `days:` instead.
    RUBY
  end

  it 'registers an offense for `seconds:` on `Date.today`' do
    expect_offense(<<~RUBY)
      Date.today.advance(seconds: 60)
                         ^^^^^^^ `seconds:` is not supported by `Date#advance`. Use `years:`, `months:`, `weeks:`, or `days:` instead.
    RUBY
  end

  it 'registers an offense for time-unit key on `Date.current`' do
    expect_offense(<<~RUBY)
      Date.current.advance(hours: 1)
                           ^^^^^ `hours:` is not supported by `Date#advance`. Use `years:`, `months:`, `weeks:`, or `days:` instead.
    RUBY
  end

  it 'registers an offense for time-unit key on `Date.yesterday`' do
    expect_offense(<<~RUBY)
      Date.yesterday.advance(hours: 1)
                             ^^^^^ `hours:` is not supported by `Date#advance`. Use `years:`, `months:`, `weeks:`, or `days:` instead.
    RUBY
  end

  it 'registers an offense for time-unit key on `Date.tomorrow`' do
    expect_offense(<<~RUBY)
      Date.tomorrow.advance(hours: 1)
                            ^^^^^ `hours:` is not supported by `Date#advance`. Use `years:`, `months:`, `weeks:`, or `days:` instead.
    RUBY
  end

  it 'registers an offense for time-unit key on `Date.new`' do
    expect_offense(<<~RUBY)
      Date.new(2024, 1, 1).advance(hours: 1)
                                   ^^^^^ `hours:` is not supported by `Date#advance`. Use `years:`, `months:`, `weeks:`, or `days:` instead.
    RUBY
  end

  it 'registers an offense for time-unit key on `Date.parse`' do
    expect_offense(<<~RUBY)
      Date.parse('2024-01-01').advance(hours: 1)
                                       ^^^^^ `hours:` is not supported by `Date#advance`. Use `years:`, `months:`, `weeks:`, or `days:` instead.
    RUBY
  end

  it 'registers an offense for time-unit key on `::Date.today`' do
    expect_offense(<<~RUBY)
      ::Date.today.advance(hours: 1)
                           ^^^^^ `hours:` is not supported by `Date#advance`. Use `years:`, `months:`, `weeks:`, or `days:` instead.
    RUBY
  end

  it 'registers both a singular offense and a date-incompatible offense for the same call' do
    expect_offense(<<~RUBY)
      Date.today.advance(hour: 1, hours: 2)
                         ^^^^ Invalid key `:hour` for `#advance`. Did you mean `hours:`?
                                  ^^^^^ `hours:` is not supported by `Date#advance`. Use `years:`, `months:`, `weeks:`, or `days:` instead.
    RUBY

    expect_correction(<<~RUBY)
      Date.today.advance(hours: 1, hours: 2)
    RUBY
  end

  # ----------------------------------------------------------------
  # No offenses
  # ----------------------------------------------------------------

  it 'does not register an offense for valid plural keys on unknown receiver' do
    expect_no_offenses(<<~RUBY)
      time.advance(years: 1, months: 2, weeks: 3, days: 4, hours: 5, minutes: 6, seconds: 7)
    RUBY
  end

  it 'does not register an offense for valid date keys on `Date.today`' do
    expect_no_offenses(<<~RUBY)
      Date.today.advance(years: 1, months: 2, weeks: 3, days: 4)
    RUBY
  end

  it 'does not register an offense for valid time-unit keys on unknown receiver' do
    expect_no_offenses(<<~RUBY)
      date_or_time.advance(hours: 1)
    RUBY
  end

  it 'does not register an offense for time-unit keys on `DateTime.now`' do
    expect_no_offenses(<<~RUBY)
      DateTime.now.advance(hours: 1, minutes: 30)
    RUBY
  end

  it 'does not register an offense for time-unit keys on `Time.now`' do
    expect_no_offenses(<<~RUBY)
      Time.now.advance(hours: 1)
    RUBY
  end

  it 'does not register an offense when `advance` is called without arguments' do
    expect_no_offenses(<<~RUBY)
      time.advance
    RUBY
  end

  it 'does not register an offense when `advance` is called with a non-hash argument' do
    expect_no_offenses(<<~RUBY)
      time.advance(options)
    RUBY
  end
end
