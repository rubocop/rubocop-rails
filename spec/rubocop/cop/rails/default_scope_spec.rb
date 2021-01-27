# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DefaultScope, :config do
  it 'registers an offense when calling `default_scope` within class' do
    expect_offense(<<~RUBY)
      class Post < ApplicationRecord
        default_scope -> { where(hidden: false) }
        ^^^^^^^^^^^^^ Avoid use of `default_scope`. It is better to use explicitly named scopes.
      end
    RUBY
  end

  it 'registers an offense when defining `default_scope` as class method' do
    expect_offense(<<~RUBY)
      class Post < ApplicationRecord
        def self.default_scope
                 ^^^^^^^^^^^^^ Avoid use of `default_scope`. It is better to use explicitly named scopes.
        end
      end
    RUBY
  end

  it 'registers an offense when defining `default_scope` as eigenclass method' do
    expect_offense(<<~RUBY)
      class Post < ApplicationRecord
        class << self
          def default_scope
              ^^^^^^^^^^^^^ Avoid use of `default_scope`. It is better to use explicitly named scopes.
          end
        end
      end
    RUBY
  end

  it 'does not register an offense when defining `default_scope` instance method' do
    expect_no_offenses(<<~RUBY)
      class Post < ApplicationRecord
        def default_scope
        end
      end
    RUBY
  end

  it 'does not register an offense when calling `default_scope` on local variable receiver' do
    expect_no_offenses(<<~RUBY)
      foo.default_scope
    RUBY
  end
end
