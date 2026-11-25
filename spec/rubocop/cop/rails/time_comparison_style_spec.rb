# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TimeComparisonStyle, :config do
  context 'when EnforcedStyle is relative' do
    let(:cop_config) { { 'EnforcedStyle' => 'relative' } }

    it do
      expect_offense(<<~RUBY)
        time < 3.days.ago
        ^^^^^^^^^^^^^^^^^ Use `time.before?(3.days.ago)` instead.
      RUBY

      expect_correction(<<~RUBY)
        time.before?(3.days.ago)
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        time > 3.days.ago
        ^^^^^^^^^^^^^^^^^ Use `time.after?(3.days.ago)` instead.
      RUBY

      expect_correction(<<~RUBY)
        time.after?(3.days.ago)
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        3.days.ago < time
        ^^^^^^^^^^^^^^^^^ Use `time.after?(3.days.ago)` instead.
      RUBY

      expect_correction(<<~RUBY)
        time.after?(3.days.ago)
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        3.days.ago > time
        ^^^^^^^^^^^^^^^^^ Use `time.before?(3.days.ago)` instead.
      RUBY

      expect_correction(<<~RUBY)
        time.before?(3.days.ago)
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        time > 2.weeks.from_now
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `time.after?(2.weeks.from_now)` instead.
      RUBY

      expect_correction(<<~RUBY)
        time.after?(2.weeks.from_now)
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        time < 1.month.since
        ^^^^^^^^^^^^^^^^^^^^ Use `time.before?(1.month.since)` instead.
      RUBY

      expect_correction(<<~RUBY)
        time.before?(1.month.since)
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        time < 1.5.hours.until
        ^^^^^^^^^^^^^^^^^^^^^^ Use `time.before?(1.5.hours.until)` instead.
      RUBY

      expect_correction(<<~RUBY)
        time.before?(1.5.hours.until)
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        time < Time.current - 3.days
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.before?(Time.current - 3.days)` instead.
      RUBY

      expect_correction(<<~RUBY)
        time.before?(Time.current - 3.days)
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        time > Time.zone.now + 1.hour
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.after?(Time.zone.now + 1.hour)` instead.
      RUBY

      expect_correction(<<~RUBY)
        time.after?(Time.zone.now + 1.hour)
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        reminder.remind_at < 3.days.ago
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `reminder.remind_at.before?(3.days.ago)` instead.
      RUBY

      expect_correction(<<~RUBY)
        reminder.remind_at.before?(3.days.ago)
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        reminder&.remind_at < 3.days.ago
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `reminder&.remind_at.before?(3.days.ago)` instead.
      RUBY

      expect_correction(<<~RUBY)
        reminder&.remind_at.before?(3.days.ago)
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        (starts_at || ends_at) < 3.days.ago
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `(starts_at || ends_at).before?(3.days.ago)` instead.
      RUBY

      expect_correction(<<~RUBY)
        (starts_at || ends_at).before?(3.days.ago)
      RUBY
    end

    it do
      expect_no_offenses(<<~RUBY)
        time.before?(3.days.ago)
        time.after?(3.days.ago)
      RUBY
    end

    it 'does not register an offense without evidence that the operands are times, ' \
       'as `before?` is not defined for numbers or strings' do
      expect_no_offenses(<<~RUBY)
        time < other_time
        time < deadline.ago
        time < n.days.ago
      RUBY
    end

    it 'does not register an offense for a duration, as it is not a time, and has no `before?`' do
      expect_no_offenses(<<~RUBY)
        elapsed < 5.minutes
      RUBY
    end

    it 'does not register an offense for a comparison with the current time, which `Rails/TimeComparison` handles' do
      expect_no_offenses(<<~RUBY)
        time < Time.current
        time.before?(Time.current)
      RUBY
    end

    it 'does not register an offense for a non-strict comparison, as it has no `before?` or `after?` counterpart' do
      expect_no_offenses(<<~RUBY)
        time <= 3.days.ago
        time >= 3.days.ago
      RUBY
    end

    it 'does not register an offense for a safe navigation argument, ' \
       'as the comparison raises `ArgumentError` on `nil`, while the correction would raise `NoMethodError`' do
      expect_no_offenses(<<~RUBY)
        3.days.ago < reminder&.remind_at
      RUBY
    end

    it 'does not register an offense for an RSpec `be` matcher, as it is not a time' do
      expect_no_offenses(<<~RUBY)
        expect(timestamp).to be > 1.day.ago
        expect(run_at).to be < 11.seconds.from_now
      RUBY
    end

    it 'does not autocorrect a safe navigation comparison, as `&.after?` is better rewritten by hand' do
      expect_offense(<<~RUBY)
        store&.created_at&.> 1.minute.ago
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `store&.created_at&.after?(1.minute.ago)` instead.
      RUBY

      expect_no_corrections
    end

    it 'does not autocorrect a `begin` block, as calling a method on it is hard to read' do
      expect_offense(<<~RUBY)
        if begin
           ^^^^^ Use `before?` instead.
          Time.parse(config[:cleared])
        rescue StandardError
          2.hours.ago
        end < 1.hour.ago
          clear
        end
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for arithmetic, as it would have to be wrapped in parentheses' do
      expect_no_offenses(<<~RUBY)
        time + 1.hour < 3.days.ago
        (time + 1.hour) < 3.days.ago
      RUBY
    end
  end

  context 'when EnforcedStyle is comparison' do
    let(:cop_config) { { 'EnforcedStyle' => 'comparison' } }

    it do
      expect_offense(<<~RUBY)
        time.before?(3.days.ago)
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 3.days.ago` instead.
      RUBY

      expect_correction(<<~RUBY)
        time < 3.days.ago
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        time.after?(3.days.ago)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `time > 3.days.ago` instead.
      RUBY

      expect_correction(<<~RUBY)
        time > 3.days.ago
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        time.before? 3.days.ago
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 3.days.ago` instead.
      RUBY

      expect_correction(<<~RUBY)
        time < 3.days.ago
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        3.days.ago.before?(time)
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `3.days.ago < time` instead.
      RUBY

      expect_correction(<<~RUBY)
        3.days.ago < time
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        time.before?(Time.current - 3.days)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < Time.current - 3.days` instead.
      RUBY

      expect_correction(<<~RUBY)
        time < Time.current - 3.days
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        reminder&.remind_at.before?(3.days.ago)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `reminder&.remind_at < 3.days.ago` instead.
      RUBY

      expect_correction(<<~RUBY)
        reminder&.remind_at < 3.days.ago
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        !time.before?(3.days.ago)
         ^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 3.days.ago` instead.
      RUBY

      expect_correction(<<~RUBY)
        !(time < 3.days.ago)
      RUBY
    end

    it do
      expect_no_offenses(<<~RUBY)
        time < 3.days.ago
        time > 3.days.ago
      RUBY
    end

    it 'does not autocorrect an argument of an operator that binds tighter than `<`, ' \
       'as `results << time < 3.days.ago` would compare `results << time` instead' do
      expect_offense(<<~RUBY)
        results << time.before?(3.days.ago)
                   ^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 3.days.ago` instead.
        flags & time.before?(3.days.ago)
                ^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 3.days.ago` instead.
        total + time.after?(3.days.ago)
                ^^^^^^^^^^^^^^^^^^^^^^^ Use `time > 3.days.ago` instead.
      RUBY

      expect_no_corrections
    end

    it do
      expect_offense(<<~RUBY)
        time.before?(3.days.ago) & active?
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 3.days.ago` instead.
      RUBY

      expect_correction(<<~RUBY)
        (time < 3.days.ago) & active?
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        done == time.before?(3.days.ago)
                ^^^^^^^^^^^^^^^^^^^^^^^^ Use `time < 3.days.ago` instead.
      RUBY

      expect_correction(<<~RUBY)
        done == time < 3.days.ago
      RUBY
    end

    it 'does not register an offense for safe navigation, as an operator cannot keep it' do
      expect_no_offenses(<<~RUBY)
        time&.before?(3.days.ago)
      RUBY
    end

    it 'does not register an offense without evidence that the operands are times, ' \
       'as `before?` may be defined by an unrelated class' do
      expect_no_offenses(<<~RUBY)
        time.before?(deadline)
        event.before?(other_event)
      RUBY
    end

    it 'does not register an offense for a comparison with the current time, which `Rails/TimeComparison` handles' do
      expect_no_offenses(<<~RUBY)
        time.before?(Time.current)
      RUBY
    end

    it do
      expect_no_offenses(<<~RUBY)
        before?(3.days.ago)
      RUBY
    end
  end
end
