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

  it 'registers an offense when using a class which does not inherit `ActionView::Helpers::FormBuilder`' do
    expect_offense(<<~RUBY)
      class Foo
        def do_something
          @template
          ^^^^^^^^^ Do not use instance variables in helpers.
          @template = do_something
          ^^^^^^^^^ Do not use instance variables in helpers.
        end
      end
    RUBY
  end
end
