# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RelativeDateConstant, :config do
  context 'direct assignment' do
    it 'accepts a method with arguments' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          EXPIRED_AT = 1.week.since(base)
        end
      RUBY
    end

    it 'accepts a lambda' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          EXPIRED_AT = -> { 1.year.ago }
        end
      RUBY
    end

    it 'accepts a lambda with numblock' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          EXPIRED_AT = -> { _1.year.ago }
        end
      RUBY
    end

    it 'accepts a proc' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          EXPIRED_AT = Proc.new { 1.year.ago }
        end
      RUBY
    end

    it 'accepts a nested proc' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          EXPIRIES = {
            yearly: Proc.new { 1.year.ago },
            monthly: Proc.new { 1.month.ago }
          }
        end
      RUBY
    end

    it 'registers an offense for ActiveSupport::Duration.since' do
      expect_offense(<<~RUBY)
        class SomeClass
          EXPIRED_AT = 1.week.since
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign `since` to constants as it will be evaluated only once.
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          def self.expired_at
            1.week.since
          end
        end
      RUBY
    end

    it 'registers and corrects an offense when using `Date.yesterday`' do
      expect_offense(<<~RUBY)
        class SomeClass
          RECENT_DATE = Date.yesterday
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign `yesterday` to constants as it will be evaluated only once.
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          def self.recent_date
            Date.yesterday
          end
        end
      RUBY
    end

    it 'registers and corrects an offense when using `Time.zone.tomorrow`' do
      expect_offense(<<~RUBY)
        class SomeClass
          FUTURE_DATE = Time.zone.tomorrow
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign `tomorrow` to constants as it will be evaluated only once.
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          def self.future_date
            Time.zone.tomorrow
          end
        end
      RUBY
    end

    it 'registers and corrects an offense when a method is chained after a relative date method' do
      expect_offense(<<~RUBY)
        class SomeClass
          START_DATE = 2.weeks.ago.to_date
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign `ago` to constants as it will be evaluated only once.
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          def self.start_date
            2.weeks.ago.to_date
          end
        end
      RUBY
    end

    it 'registers an offense for exclusive end range' do
      expect_offense(<<~RUBY)
        class SomeClass
          TRIAL_PERIOD = DateTime.current..1.day.since
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign `since` to constants as it will be evaluated only once.
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          def self.trial_period
            DateTime.current..1.day.since
          end
        end
      RUBY
    end

    it 'registers an offense for inclusive end range' do
      expect_offense(<<~RUBY)
        class SomeClass
          TRIAL_PERIOD = DateTime.current...1.day.since
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign `since` to constants as it will be evaluated only once.
        end
      RUBY
    end

    it 'registers an offense for exclusive begin range' do
      expect_offense(<<~RUBY)
        class SomeClass
          TRIAL_PERIOD = 1.day.ago..DateTime.current
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign `ago` to constants as it will be evaluated only once.
        end
      RUBY
    end

    it 'registers an offense for inclusive begin range' do
      expect_offense(<<~RUBY)
        class SomeClass
          TRIAL_PERIOD = 1.day.ago...DateTime.current
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign `ago` to constants as it will be evaluated only once.
        end
      RUBY
    end
  end

  context 'or assignment' do
    it 'registers an offense for relative date in ||=' do
      expect_offense(<<~RUBY)
        class SomeClass
          EXPIRED_AT ||= 1.week.since
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign `since` to constants as it will be evaluated only once.
        end
      RUBY
    end
  end

  context 'mass assignment' do
    it 'registers an offense for relative date in multiple assignment' do
      expect_offense(<<~RUBY)
        class SomeClass
          START, A, x = 2.weeks.ago, 1.week.since, 5
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign `ago` to constants as it will be evaluated only once.
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign `since` to constants as it will be evaluated only once.
        end
      RUBY
    end
  end

  context 'when using multiple assignment' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          FOO, BAR = *do_something
        end
      RUBY
    end
  end
end
