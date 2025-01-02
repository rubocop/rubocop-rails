# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::PrependTrueOptionOnBeforeDestroy, :config do
  it 'registers an offense when `before_destroy` without `prepend: true` option.' do
    expect_offense(<<~RUBY)
      class User < ActiveRecord::Base
        has_many :comments, dependent: :destroy

        before_destroy :prevent_deletion_if_comments_exists
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add `prepend: true` option on `before_destroy` to prevent unexpected deletion of associated records.
      end
    RUBY

    expect_correction(<<~RUBY)
      class User < ActiveRecord::Base
        has_many :comments, dependent: :destroy
      
        before_destroy :prevent_deletion_if_comments_exists, prepend: true
      end
    RUBY
  end

  it 'registers no offense when `before_destroy` with `prepend: true` option' do
    expect_no_offenses(<<~RUBY)
      class User < ActiveRecord::Base
        has_many :comments, dependent: :destroy

        before_destroy :prevent_deletion_if_comments_exists, prepend: true
      end
    RUBY
  end
end
