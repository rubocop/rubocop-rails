# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::OrderById, :config do
  it 'registers an offense when ordering by `:id` with implicit direction' do
    expect_offense(<<~RUBY)
      User.order(:id)
           ^^^^^^^^^^ Do not use the `id` column for ordering. Use a timestamp column to order chronologically.
    RUBY
  end

  it 'registers an offense when ordering by `:id` with explicit direction' do
    expect_offense(<<~RUBY)
      User.order(id: :asc)
           ^^^^^^^^^^^^^^^ Do not use the `id` column for ordering. Use a timestamp column to order chronologically.
    RUBY
  end

  it 'registers an offense when ordering by `primary_key` with implicit direction' do
    expect_offense(<<~RUBY)
      scope :chronological, -> { order(primary_key) }
                                 ^^^^^^^^^^^^^^^^^^ Do not use the `id` column for ordering. Use a timestamp column to order chronologically.
    RUBY
  end

  it 'registers an offense when ordering by `primary_key` with explicit direction' do
    expect_offense(<<~RUBY)
      scope :chronological, -> { order(primary_key => :asc) }
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use the `id` column for ordering. Use a timestamp column to order chronologically.
    RUBY
  end

  it 'does not register an offense when ordering by non id column' do
    expect_no_offenses(<<~RUBY)
      User.order(:created_at)
    RUBY
  end

  it 'does not register an offense when ordering by multiple columns, including id' do
    expect_no_offenses(<<~RUBY)
      User.order(id: :asc, created_at: :desc)
    RUBY
  end
end
