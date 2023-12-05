# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::PluckId, :config do
  it 'registers an offense and corrects when using `pluck(:id)`' do
    expect_offense(<<~RUBY)
      User.pluck(:id)
           ^^^^^^^^^^ Use `ids` instead of `pluck(:id)`.
    RUBY

    expect_correction(<<~RUBY)
      User.ids
    RUBY
  end

  it 'registers an offense and corrects when using `pluck(:id)` with safe navigation' do
    expect_offense(<<~RUBY)
      User&.pluck(:id)
            ^^^^^^^^^^ Use `ids` instead of `pluck(:id)`.
    RUBY

    expect_correction(<<~RUBY)
      User&.ids
    RUBY
  end

  it 'registers an offense and corrects when using `pluck(primary_key)`' do
    expect_offense(<<~RUBY)
      def self.user_ids
        pluck(primary_key)
        ^^^^^^^^^^^^^^^^^^ Use `ids` instead of `pluck(primary_key)`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def self.user_ids
        ids
      end
    RUBY
  end

  it 'does not register an offense when plucking non :id' do
    expect_no_offenses(<<~RUBY)
      user.posts.pluck(:votes)
    RUBY
  end

  it 'does not register an offense when plucking multiple columns' do
    expect_no_offenses(<<~RUBY)
      user.posts.pluck(:id, :votes)
    RUBY
  end

  it 'does not register an offense when inside `where` clause' do
    expect_no_offenses(<<~RUBY)
      Post.where(user_id: User.pluck(:id))
    RUBY
  end
end
