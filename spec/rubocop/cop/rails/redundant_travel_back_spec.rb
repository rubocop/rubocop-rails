# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RedundantTravelBack, :config do
  context '>= Rails 5.2', :rails52 do
    it 'registers and corrects an offense when using `travel_back` in `teardown` method' do
      expect_offense(<<~RUBY)
        def teardown
          do_something
          travel_back
          ^^^^^^^^^^^ Redundant `travel_back` detected.
        end
      RUBY

      expect_correction(<<~RUBY)
        def teardown
          do_something
        end
      RUBY
    end

    it 'registers and corrects an offense when using `travel_back` in `after` block' do
      expect_offense(<<~RUBY)
        after do
          do_something
          travel_back
          ^^^^^^^^^^^ Redundant `travel_back` detected.
        end
      RUBY

      expect_correction(<<~RUBY)
        after do
          do_something
        end
      RUBY
    end

    it 'does not register an offense when using `travel_back` outside of `teardown` method' do
      expect_no_offenses(<<~RUBY)
        def do_something
          travel_back
        end
      RUBY
    end

    it 'does not register an offense when using `travel_back` outside of `after` block' do
      expect_no_offenses(<<~RUBY)
        do_something do
          travel_back
        end
      RUBY
    end
  end

  context '<= Rails 5.1', :rails51 do
    it 'does not register an offense when using `travel_back` in `teardown` method' do
      expect_no_offenses(<<~RUBY)
        def teardown
          do_something
          travel_back
        end
      RUBY
    end

    it 'does not register an offense when using `travel_back` in `after` block' do
      expect_no_offenses(<<~RUBY)
        after do
          do_something
          travel_back
        end
      RUBY
    end
  end
end
