# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TimeComparison, :config do
  it do
    expect_offense(<<~RUBY)
      time < Time.current
      ^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time > Time.current
      ^^^^^^^^^^^^^^^^^^^ Use `time.future?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.future?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current > time
      ^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current < time
      ^^^^^^^^^^^^^^^^^^^ Use `time.future?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.future?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time < ::Time.current
      ^^^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time < Time.zone.now
      ^^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time.before?(Time.current)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time.after?(Time.current)
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.future?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.future?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current.before?(time)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.future?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.future?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current.after?(time)
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.zone.now.before?(time)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.future?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.future?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time&.before?(Time.current)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time&.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time&.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      reminder&.remind_at.before?(Time.current)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `reminder&.remind_at.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      reminder&.remind_at.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current&.after?(time)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      reminder.remind_at < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `reminder.remind_at.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      reminder.remind_at.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      times[0] < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^ Use `times[0].past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      times[0].past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      (starts_at || ends_at) < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `(starts_at || ends_at).past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      (starts_at || ends_at).past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      reminder&.remind_at < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `reminder&.remind_at.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      reminder&.remind_at.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time + 1.hour < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 1.hour.ago` instead.
    RUBY

    expect_correction(<<~RUBY)
      time < 1.hour.ago
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time - 30.minutes > Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time > 30.minutes.from_now` instead.
    RUBY

    expect_correction(<<~RUBY)
      time > 30.minutes.from_now
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current < time + 1.hour
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time > 1.hour.ago` instead.
    RUBY

    expect_correction(<<~RUBY)
      time > 1.hour.ago
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.zone.now > time - 1.hour
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 1.hour.from_now` instead.
    RUBY

    expect_correction(<<~RUBY)
      time < 1.hour.from_now
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      (time + 1.hour) < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 1.hour.ago` instead.
    RUBY

    expect_correction(<<~RUBY)
      time < 1.hour.ago
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time + 24.hours < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 24.hours.ago` instead.
    RUBY

    expect_correction(<<~RUBY)
      time < 24.hours.ago
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time + 1.5.hours < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 1.5.hours.ago` instead.
    RUBY

    expect_correction(<<~RUBY)
      time < 1.5.hours.ago
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time + 90.seconds < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 90.seconds.ago` instead.
    RUBY

    expect_correction(<<~RUBY)
      time < 90.seconds.ago
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      (time + 1.hour).before?(Time.current)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.before?(1.hour.ago)` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.before?(1.hour.ago)
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current.before?(time + 1.hour)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.after?(1.hour.ago)` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.after?(1.hour.ago)
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      (time + 1.hour).past?
      ^^^^^^^^^^^^^^^^^^^^^ Use `time.before?(1.hour.ago)` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.before?(1.hour.ago)
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      (time - 1.hour).future?
      ^^^^^^^^^^^^^^^^^^^^^^^ Use `time.after?(1.hour.from_now)` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.after?(1.hour.from_now)
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      reminder&.remind_at + 1.hour < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `reminder&.remind_at < 1.hour.ago` instead.
    RUBY

    expect_correction(<<~RUBY)
      reminder&.remind_at < 1.hour.ago
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current - time > 1.hour
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 1.hour.ago` instead.
    RUBY

    expect_correction(<<~RUBY)
      time < 1.hour.ago
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current - time < 1.hour
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time > 1.hour.ago` instead.
    RUBY

    expect_correction(<<~RUBY)
      time > 1.hour.ago
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      1.hour < Time.current - time
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 1.hour.ago` instead.
    RUBY

    expect_correction(<<~RUBY)
      time < 1.hour.ago
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      (Time.current - time) > 1.hour
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 1.hour.ago` instead.
    RUBY

    expect_correction(<<~RUBY)
      time < 1.hour.ago
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.zone.now - time > 1.hour
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 1.hour.ago` instead.
    RUBY

    expect_correction(<<~RUBY)
      time < 1.hour.ago
    RUBY
  end

  it do
    expect_no_offenses(<<~RUBY)
      past?
    RUBY
  end

  it 'does not register an offense for an RSpec `be` matcher, as it is not a time' do
    expect_no_offenses(<<~RUBY)
      expect(time).to be < Time.current
    RUBY
  end

  it 'does not register an offense when a day would have to be moved across the comparison, ' \
     'as a calendar day is not always 24 hours long (DST)' do
    expect_no_offenses(<<~RUBY)
      time + 1.day < Time.current
      (time + 1.day) < Time.current
      time + 1.week < Time.current
      (time + 1.day).past?
    RUBY
  end

  it 'does not register an offense when a month would have to be moved across the comparison, ' \
     'as end-of-month clamping makes it irreversible: Jan 31 + 1 month is Feb 28, and Feb 28 - 1 month is Jan 28' do
    expect_no_offenses(<<~RUBY)
      time + 1.month < Time.current
      time + 1.year < Time.current
    RUBY
  end

  it 'does not register an offense for an operand of an unknown unit, ' \
     'as it may be a calendar duration, or an Integer number of seconds that has no `ago`' do
    expect_no_offenses(<<~RUBY)
      time + backoff < Time.current
    RUBY
  end

  it 'does not register an offense for elapsed time compared with a calendar duration, ' \
     'as subtracting times gives absolute seconds, while `1.day.ago` is a calendar day back' do
    expect_no_offenses(<<~RUBY)
      Time.current - time > 1.day
    RUBY
  end

  it 'does not register an offense for a safe navigation argument, ' \
     'as the comparison raises `ArgumentError` on `nil`, while the correction would raise `NoMethodError`' do
    expect_no_offenses(<<~RUBY)
      Time.current > reminder&.remind_at
      Time.current.after?(reminder&.remind_at)
      Time.current - reminder&.remind_at > 1.hour
    RUBY
  end

  it 'does not register an offense for a duration on a non-literal receiver, ' \
     'as it may be an unrelated method that returns a number' do
    expect_no_offenses(<<~RUBY)
      time + shift.hours < Time.current
      Time.current - time > shift.hours
    RUBY
  end

  it 'does not register an offense for more than one duration, as only one of them can be moved' do
    expect_no_offenses(<<~RUBY)
      time + 1.hour + 30.minutes < Time.current
    RUBY
  end

  it 'does not register an offense for a non-strict comparison, as `past?` and `future?` exclude the current time' do
    expect_no_offenses(<<~RUBY)
      time <= Time.current
      time >= Time.current
    RUBY
  end

  it 'does not register an offense for an equality check, as it has no `past?` or `future?` counterpart' do
    expect_no_offenses(<<~RUBY)
      time == Time.current
    RUBY
  end

  it 'does not register an offense for a comparison with `Date.current`, ' \
     'as it is the beginning of the day: a time earlier this morning is after it, but still in the past' do
    expect_no_offenses(<<~RUBY)
      time > Date.current
      time > Time.zone.today
    RUBY
  end

  it 'does not register an offense for `Time.now`, which `Rails/TimeZone` replaces first' do
    expect_no_offenses(<<~RUBY)
      time < Time.now
    RUBY
  end

  it 'does not register an offense for a value derived from the current time, as it is not the current time' do
    expect_no_offenses(<<~RUBY)
      year < Time.current.year
      time < Time.current.beginning_of_day
    RUBY
  end
end
