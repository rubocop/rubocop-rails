# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActiveRecordCallbacksOrder do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects when declared callbacks are not correctly ordered' do
    expect_offense(<<~RUBY)
      class User < ApplicationRecord
        scope :admins, -> { where(admin: true) }

        after_commit :after_commit_callback
        after_save :after_save_callback
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `after_save` is supposed to appear before `after_commit`.

        def some_method
        end

        before_validation :before_validation_callback
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `before_validation` is supposed to appear before `after_save`.
        some_other_macros :foo
      end
    RUBY

    expect_correction(<<~RUBY)
      class User < ApplicationRecord
        scope :admins, -> { where(admin: true) }

        before_validation :before_validation_callback
        after_save :after_save_callback
        after_commit :after_commit_callback

        def some_method
        end

        some_other_macros :foo
      end
    RUBY
  end

  it 'correcly autocorrects when there is a comment for callback method' do
    new_source = autocorrect_source(<<~RUBY)
      class User < ApplicationRecord
        # This is a
        # multiline
        # comment for after_commit.
        after_commit :after_commit_callback
        # This is another
        # multiline
        # comment for after_save.
        after_save :after_save_callback
      end
    RUBY

    expect(new_source).to eq(<<~RUBY)
      class User < ApplicationRecord
        # This is another
        # multiline
        # comment for after_save.
        after_save :after_save_callback
        # This is a
        # multiline
        # comment for after_commit.
        after_commit :after_commit_callback
      end
    RUBY
  end

  it 'correcly autocorrects when there are multiple callbacks of the same type' do
    new_source = autocorrect_source(<<~RUBY)
      class User < ApplicationRecord
        after_commit :after_commit_callback1
        after_save :after_save_callback
        after_commit :after_commit_callback2
      end
    RUBY

    expect(new_source).to eq(<<~RUBY)
      class User < ApplicationRecord
        after_save :after_save_callback
        after_commit :after_commit_callback1
        after_commit :after_commit_callback2
      end
    RUBY
  end

  it 'preserves the original order of callbacks of the same type' do
    expect_offense(<<~RUBY)
      class User < ApplicationRecord
        after_commit :after_commit_callback
        after_save :after_save_callback1
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `after_save` is supposed to appear before `after_commit`.
        after_save :after_save_callback2
      end
    RUBY

    expect_correction(<<~RUBY)
      class User < ApplicationRecord
        after_save :after_save_callback1
        after_save :after_save_callback2
        after_commit :after_commit_callback
      end
    RUBY
  end

  it 'does not register an offense when declared callbacks are correctly ordered' do
    expect_no_offenses(<<~RUBY)
      class User < ApplicationRecord
        scope :admins, -> { where(admin: true) }

        before_validation :before_validation_callback
        after_save :after_save_callback

        def some_method
        end

        after_commit :after_commit_callback
      end
    RUBY
  end

  it 'does not register an offense when there are no callbacks' do
    expect_no_offenses(<<~RUBY)
      class User < ApplicationRecord
        def some_method
        end
      end
    RUBY
  end
end
