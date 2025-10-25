# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DuplicateScope, :config do
  it 'registers an offense when a duplicate scope with the same `where` clauses is detected' do
    expect_offense(<<~RUBY)
      class Post < ApplicationRecord
        scope :visible, -> { where(visible: true) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Multiple scopes share this same expression.
        scope :hidden, -> { where(visible: true) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Multiple scopes share this same expression.
        scope :new, -> { where(created_at: 1.week.ago..Date.current) }
        scope :popular, -> { where(comments_count: 1000..Float::INFINITY) }
      end
    RUBY
  end

  it 'registers an offense when a duplicate scope with the same expression is detected' do
    expect_offense(<<~RUBY)
      class Post < ApplicationRecord
        scope :with_visibility, ->(value) { where(visible: value) }

        scope :visible, -> { with_visibility(true) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Multiple scopes share this same expression.
        scope :hidden, -> { with_visibility(true) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Multiple scopes share this same expression.
      end
    RUBY
  end

  it 'does not register an offense when there are no duplicates' do
    expect_no_offenses(<<~RUBY)
      class Post < ApplicationRecord
        scope :visible, -> { where(visible: true) }
        scope :hidden, -> { where(visible: false) }
        scope :new, -> { where(created_at: 1.week.ago..Date.current) }
        scope :popular, -> { where(comments_count: 1000..Float::INFINITY) }
      end
    RUBY
  end
end
