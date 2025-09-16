# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DateAndTimeCalculation, :config do
  context 'with `Time.zone.now`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Time.zone.now
        ^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        Time.current
      RUBY
    end
  end

  context 'with `::Time.zone.now`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ::Time.zone.now
        ^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        ::Time.current
      RUBY
    end
  end

  context 'with `Time.zone.today`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Time.zone.today
        ^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        Date.current
      RUBY
    end
  end

  context 'with `::Time.zone.today`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ::Time.zone.today
        ^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        ::Date.current
      RUBY
    end
  end

  context 'with `Time.current.to_date`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Time.current.to_date
        ^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        Date.current
      RUBY
    end
  end

  context 'with `Date.current.tomorrow`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Date.current.tomorrow
        ^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        Date.tomorrow
      RUBY
    end
  end

  context 'with `Date.current.yesterday`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Date.current.yesterday
        ^^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        Date.yesterday
      RUBY
    end
  end

  context 'with `date == Date.current`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        date == Date.current
        ^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        date.today?
      RUBY
    end
  end

  context 'with `Date.current == date`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Date.current == date
        ^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        date.today?
      RUBY
    end
  end

  context 'with `date == Date.tomorrow`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        date == Date.tomorrow
        ^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        date.tomorrow?
      RUBY
    end
  end

  context 'with `Date.tomorrow == date`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Date.tomorrow == date
        ^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        date.tomorrow?
      RUBY
    end
  end

  context 'with `date == Date.yesterday`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        date == Date.yesterday
        ^^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        date.yesterday?
      RUBY
    end
  end

  context 'with `Date.yesterday == date`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Date.yesterday == date
        ^^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        date.yesterday?
      RUBY
    end
  end

  context 'with `Time.current - n.days`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Time.current - n.days
        ^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        n.days.ago
      RUBY
    end
  end

  context 'with `Time.current + n.days`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Time.current + n.days
        ^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        n.days.since
      RUBY
    end
  end

  context 'with `::Time.current`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ::Time.current - n.days
        ^^^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        n.days.ago
      RUBY
    end
  end

  context 'with `Date.current - 1' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Date.current - 1
        ^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        Date.yesterday
      RUBY
    end
  end

  context 'with `Date.current - 1.day`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Date.current - 1.day
        ^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        Date.yesterday
      RUBY
    end
  end

  context 'with `Date.current + 1' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Date.current + 1
        ^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        Date.tomorrow
      RUBY
    end
  end

  context 'with `Date.current + 1.day`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Date.current + 1.day
        ^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        Date.tomorrow
      RUBY
    end
  end

  context 'with `time > Time.current`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        time > Time.current
        ^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        time.future?
      RUBY
    end
  end

  context 'with `time.after?(Time.current)`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        time.after?(Time.current)
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        time.future?
      RUBY
    end
  end

  context 'with `Time.current < time`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Time.current < time
        ^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        time.future?
      RUBY
    end
  end

  context 'with `Time.current.before?(time)`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Time.current.before?(time)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        time.future?
      RUBY
    end
  end

  context 'with `time < Time.current`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        time < Time.current
        ^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        time.past?
      RUBY
    end
  end

  context 'with `time.before?(Time.current)`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        time.before?(Time.current)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        time.past?
      RUBY
    end
  end

  context 'with `Time.current > time`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Time.current > time
        ^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        time.past?
      RUBY
    end
  end

  context 'with `Time.current.after?(time)`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Time.current.after?(time)
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        time.past?
      RUBY
    end
  end

  context 'with `time + 1.hour > Time.current`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        time + 1.hour > Time.current
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        (time + 1.hour).future?
      RUBY
    end
  end

  context 'with `@time > Time.current`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        @time > Time.current
        ^^^^^^^^^^^^^^^^^^^^ Prefer ActiveSupport date and time helper.
      RUBY

      expect_correction(<<~RUBY)
        @time.future?
      RUBY
    end
  end
end
