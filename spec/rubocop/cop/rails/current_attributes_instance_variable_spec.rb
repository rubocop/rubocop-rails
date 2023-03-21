# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::CurrentAttributesInstanceVariable, :config do
  it 'registers an offense when using instances variables in a CurrentAttributes subclass' do
    expect_offense(<<~RUBY)
      class Foo < ActiveSupport::CurrentAttributes
        def do_something
          @template
          ^^^^^^^^^ Do not use instance variables in instances of CurrentAttributes.
          @template = do_something
          ^^^^^^^^^ Do not use instance variables in instances of CurrentAttributes.

          @account ||= user.account
          ^^^^^^^^ Do not use instance variables in instances of CurrentAttributes.
        end
      end
    RUBY
  end

  it 'does not register an offense in an unrelated context' do
    expect_no_offenses(<<~RUBY)
      @account ||= user.account
    RUBY
  end
end
