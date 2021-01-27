# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::AfterCommitOverride, :config do
  it 'registers an offense when using `after_*_commit` callbacks with the same name' do
    expect_offense(<<~RUBY)
      class User < ApplicationRecord
        after_create_commit :log_action
        after_commit :log_action, on: :update
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ There can only be one `after_*_commit :log_action` hook defined for a model.
        after_destroy_commit :log_action
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ There can only be one `after_*_commit :log_action` hook defined for a model.
      end
    RUBY
  end

  it 'does not register an offense when using `after_*_commit` callbacks with different names' do
    expect_no_offenses(<<~RUBY)
      class User < ApplicationRecord
        after_create_commit :log_create_action
        after_destroy_commit :log_destroy_action
      end
    RUBY
  end

  it 'does not register an offense when using different callback types with the same name' do
    expect_no_offenses(<<~RUBY)
      class User < ApplicationRecord
        before_save :log_action
        after_create_commit :log_action
      end
    RUBY
  end

  it 'does not register an offense when the callbacks are defined with lambdas' do
    expect_no_offenses(<<~RUBY)
      class User < ApplicationRecord
        after_commit -> { foo }
        after_destroy_commit -> { foo }
      end
    RUBY
  end

  it 'ignores after_commit method call without arguments' do
    expect_no_offenses(<<~RUBY)
      class User < ApplicationRecord
        after_commit
        after_destroy_commit
      end
    RUBY
  end
end
