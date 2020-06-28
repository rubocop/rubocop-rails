# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::PluckInWhere do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects when using `pluck` in `where`' do
    expect_offense(<<~RUBY)
      Post.where(user_id: User.pluck(:id))
                               ^^^^^ Use `select` instead of `pluck` within `where` query method.
    RUBY

    expect_correction(<<~RUBY)
      Post.where(user_id: User.select(:id))
    RUBY
  end

  it 'registers an offense and corrects when using `pluck` in `rewhere`' do
    expect_offense(<<~RUBY)
      Post.rewhere('user_id IN (?)', User.pluck(:id))
                                          ^^^^^ Use `select` instead of `pluck` within `where` query method.
    RUBY

    expect_correction(<<~RUBY)
      Post.rewhere('user_id IN (?)', User.select(:id))
    RUBY
  end

  it 'does not register an offense when using `select` in `where`' do
    expect_no_offenses(<<~RUBY)
      Post.where(user_id: User.select(:id))
    RUBY
  end

  it 'does not register an offense when using `pluck` chained with other method calls in `where`' do
    expect_no_offenses(<<~RUBY)
      Post.where(user_id: User.pluck(:id).map(&:to_i))
    RUBY
  end

  it 'does not register an offense when using `select` in query methods other than `where`' do
    expect_no_offenses(<<~RUBY)
      Post.order(columns.pluck(:name))
    RUBY
  end
end
