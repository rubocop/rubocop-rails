# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::FreezeTime, :config do
  context 'Rails 5.1', :rails51 do
    it 'does not register an offense when using `travel_to` with an argument of the current time' do
      expect_no_offenses('travel_to(Time.now)')
      expect_no_offenses('travel_to(Time.new)')
      expect_no_offenses('travel_to(DateTime.now)')
      expect_no_offenses('travel_to(Time.current)')
      expect_no_offenses('travel_to(Time.zone.now)')
    end

    it 'does not register an offense when using `travel_to` with an argument of the current time and `do-end` block' do
      expect_no_offenses(<<~RUBY)
        travel_to(Time.now) do
          do_something
        end
      RUBY
    end

    it 'does not register an offense when using `travel_to` with an argument of the current time and `{}` block' do
      expect_no_offenses(<<~RUBY)
        travel_to(Time.now) { do_something }
      RUBY
    end

    it 'does not register an offense when using `travel_to` with an argument of the current time and proc argument' do
      expect_no_offenses(<<~RUBY)
        around do |example|
          travel_to(Time.current, &example)
        end
      RUBY
    end
  end

  context 'Rails 5.2', :rails52 do
    it 'registers an offense when using `travel_to` with an argument of the current time' do
      expect_offense(<<~RUBY)
        travel_to(Time.now)
        ^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
        travel_to(Time.new)
        ^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
        travel_to(DateTime.now)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
        travel_to(Time.current)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
        travel_to(Time.zone.now)
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
        travel_to(Time.now.in_time_zone)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
        travel_to(Time.current.to_time)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
        travel_to(::Time.now)
        ^^^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
        travel_to(::DateTime.now)
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
        travel_to(::Time.zone.now)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
      RUBY

      expect_correction(<<~RUBY)
        freeze_time
        freeze_time
        freeze_time
        freeze_time
        freeze_time
        freeze_time
        freeze_time
        freeze_time
        freeze_time
        freeze_time
      RUBY
    end

    it 'registers an offense when using `travel_to` with an argument of the current time and `do-end` block' do
      expect_offense(<<~RUBY)
        travel_to(Time.now) do
        ^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
          do_something
        end
      RUBY

      expect_correction(<<~RUBY)
        freeze_time do
          do_something
        end
      RUBY
    end

    it 'registers an offense when using `travel_to` with an argument of the current time and `{}` block' do
      expect_offense(<<~RUBY)
        travel_to(Time.now) { do_something }
        ^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
      RUBY

      expect_correction(<<~RUBY)
        freeze_time { do_something }
      RUBY
    end

    it 'registers an offense when using `travel_to` with an argument of the current time and proc argument' do
      expect_offense(<<~RUBY)
        around do |example|
          travel_to(Time.current, &example)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `freeze_time` instead of `travel_to`.
        end
      RUBY

      expect_correction(<<~RUBY)
        around do |example|
          freeze_time(&example)
        end
      RUBY
    end

    it 'does not register an offense when using `freeze_time`' do
      expect_no_offenses(<<~RUBY)
        freeze_time
      RUBY
    end

    it 'does not register an offense when using `travel_to` with an argument of the not current time' do
      expect_no_offenses(<<~RUBY)
        travel_to(Time.current.yesterday)
        travel_to(Time.zone.tomorrow)
        travel_to(DateTime.next_day)
        travel_to(Time.zone.yesterday.in_time_zone)
      RUBY
    end

    it 'does not register an offense when using `travel_to` with an argument of `current` method without receiver' do
      expect_no_offenses(<<~RUBY)
        travel_to(current)
      RUBY
    end

    it 'does not register an offense when using `travel_to` with an argument of `DateTime.new` with arguments' do
      expect_no_offenses(<<~RUBY)
        travel_to(DateTime.new(2022, 5, 3, 12, 0, 0))
      RUBY
    end

    it 'does not register an offense when using `travel_to` with an argument of `Time.new(...).in_time_zone`' do
      expect_no_offenses(<<~RUBY)
        travel_to(Time.new(2019, 4, 3, 12, 30).in_time_zone)
      RUBY
    end

    it 'does not register an offense when using `travel_to` without argument' do
      expect_no_offenses(<<~RUBY)
        travel_to
      RUBY
    end
  end
end
