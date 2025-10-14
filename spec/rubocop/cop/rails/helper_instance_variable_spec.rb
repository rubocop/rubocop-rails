# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::HelperInstanceVariable, :config do
  it 'reports uses of instance variables' do
    expect_offense(<<~'RUBY')
      def welcome_message
        "Hello #{@user.name}"
                 ^^^^^ Do not use instance variables in helpers.
      end
    RUBY
  end

  it 'reports instance variable assignments' do
    expect_offense(<<~RUBY)
      def welcome_message(user)
        @user_name = user.name
        ^^^^^^^^^^ Do not use instance variables in helpers.
      end
    RUBY
  end

  specify do
    expect_no_offenses(<<~'RUBY')
      def welcome_message(user)
        "Hello #{user.name}"
      end
    RUBY
  end

  it 'does not register an offense when using memoization' do
    expect_no_offenses(<<~RUBY)
      def foo
        @cache ||= heavy_load
      end
    RUBY
  end

  it 'does not register an offense when a class which inherits `ActionView::Helpers::FormBuilder`' do
    expect_no_offenses(<<~RUBY)
      class MyFormBuilder < ActionView::Helpers::FormBuilder
        def do_something
          @template
          @template = do_something
        end
      end
    RUBY
  end

  it 'does not register an offense when a class which inherits `::ActionView::Helpers::FormBuilder`' do
    expect_no_offenses(<<~RUBY)
      class MyFormBuilder < ::ActionView::Helpers::FormBuilder
        def do_something
          @template
          @template = do_something
        end
      end
    RUBY
  end

  it 'does not register an offense when an instance variable is defined within a class' do
    expect_no_offenses(<<~RUBY)
      module ButtonHelper
        class Button
          def initialize(text:)
            @text = text
          end
        end

        def button(**args)
          render Button.new(**args)
        end
      end
    RUBY
  end
end
