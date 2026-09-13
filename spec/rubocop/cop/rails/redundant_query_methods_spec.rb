# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RedundantQueryMethods, :config do
  described_class::QUERY_METHODS.each do |method|
    context "with `#{method}`" do
      let(:arguments) { method == :distinct ? '' : '(:user)' }

      it 'registers an offense when the call is repeated with the same arguments' do
        expect_offense(<<~RUBY, method: method, arguments: arguments)
          Post.%{method}%{arguments}.%{method}%{arguments}
               _{method}_{arguments}^^{method}^{arguments} Redundant `%{method}` detected.
        RUBY

        expect_correction(<<~RUBY)
          Post.#{method}#{arguments}
        RUBY
      end
    end
  end

  it 'registers an offense when the repeated calls are separated by another call' do
    expect_offense(<<~RUBY)
      Post.order(:rank).where(published: true).order(:rank)
                                              ^^^^^^^^^^^^^ Redundant `order` detected.
    RUBY

    expect_correction(<<~RUBY)
      Post.order(:rank).where(published: true)
    RUBY
  end

  it 'registers an offense for each redundant call when one is repeated three times' do
    expect_offense(<<~RUBY)
      Post.joins(:user).joins(:user).joins(:user)
                                    ^^^^^^^^^^^^^ Redundant `joins` detected.
                       ^^^^^^^^^^^^^ Redundant `joins` detected.
    RUBY

    expect_correction(<<~RUBY)
      Post.joins(:user)
    RUBY
  end

  it 'registers an offense in a multiline chain and does not leave a blank line' do
    expect_offense(<<~RUBY)
      Post
        .eager_load(:user)
        .eager_load(:user)
        ^^^^^^^^^^^^^^^^^^ Redundant `eager_load` detected.
        .where(published: true)
    RUBY

    expect_correction(<<~RUBY)
      Post
        .eager_load(:user)
        .where(published: true)
    RUBY
  end

  it 'registers an offense with a hash argument' do
    expect_offense(<<~RUBY)
      Post.order(rank: :desc).order(rank: :desc)
                             ^^^^^^^^^^^^^^^^^^^ Redundant `order` detected.
    RUBY

    expect_correction(<<~RUBY)
      Post.order(rank: :desc)
    RUBY
  end

  it 'registers an offense with multiple arguments' do
    expect_offense(<<~RUBY)
      Post.select(:id, :title).select(:id, :title)
                              ^^^^^^^^^^^^^^^^^^^^ Redundant `select` detected.
    RUBY

    expect_correction(<<~RUBY)
      Post.select(:id, :title)
    RUBY
  end

  it 'registers an offense with an array argument' do
    expect_offense(<<~RUBY)
      Post.group([:rank, :title]).group([:rank, :title])
                                 ^^^^^^^^^^^^^^^^^^^^^^^ Redundant `group` detected.
    RUBY

    expect_correction(<<~RUBY)
      Post.group([:rank, :title])
    RUBY
  end

  it 'registers an offense when the chain has no explicit receiver' do
    expect_offense(<<~RUBY)
      scope :with_user, -> { eager_load(:user).eager_load(:user) }
                                              ^^^^^^^^^^^^^^^^^^ Redundant `eager_load` detected.
    RUBY

    expect_correction(<<~RUBY)
      scope :with_user, -> { eager_load(:user) }
    RUBY
  end

  it 'does not register an offense when the arguments differ' do
    expect_no_offenses(<<~RUBY)
      Post.order(:rank).order(:title)
    RUBY
  end

  it 'does not register an offense when a symbol and a string are used' do
    expect_no_offenses(<<~RUBY)
      Post.order(:rank).order('rank')
    RUBY
  end

  it 'does not register an offense when the hash arguments differ' do
    expect_no_offenses(<<~RUBY)
      Post.order(rank: :desc).order(rank: :asc)
    RUBY
  end

  it 'does not register an offense for `distinct(false)` after `distinct`' do
    expect_no_offenses(<<~RUBY)
      Post.distinct.distinct(false)
    RUBY
  end

  it 'does not register an offense when the repeated argument is not a literal' do
    expect_no_offenses(<<~RUBY)
      Post.joins(next_association!).joins(next_association!)
    RUBY
  end

  it 'does not register an offense when an argument contains a non-literal' do
    expect_no_offenses(<<~RUBY)
      Post.order(rank: direction).order(rank: direction)
    RUBY
  end

  it 'does not register an offense when the later call takes a block' do
    expect_no_offenses(<<~RUBY)
      Post.distinct.distinct { |post| post.rank }
    RUBY
  end

  it 'does not register an offense when both calls take blocks' do
    expect_no_offenses(<<~RUBY)
      Post.select { |post| post.published? }.select { |post| post.published? }
    RUBY
  end

  it 'does not register an offense for a single call' do
    expect_no_offenses(<<~RUBY)
      Post.eager_load(:user).where(published: true)
    RUBY
  end

  it 'does not register an offense for different query methods' do
    expect_no_offenses(<<~RUBY)
      Post.joins(:user).left_joins(:user)
    RUBY
  end

  it 'does not register an offense for repeats on separate receivers' do
    expect_no_offenses(<<~RUBY)
      [Post.order(:rank), Comment.order(:rank)]
    RUBY
  end

  # `limit`, `offset` and `reorder` are out of scope: the last call replaces the
  # earlier ones rather than merging, so the offense is a different shape. These
  # repeats use equal arguments so they would be registered if the methods were
  # added to `QUERY_METHODS` without a separate decision.
  it 'does not register an offense for `limit`, `offset` or `reorder`' do
    expect_no_offenses(<<~RUBY)
      Post.limit(2).limit(2).offset(9).offset(9).reorder(:rank).reorder(:rank)
    RUBY
  end

  it 'does not register an offense for `where`' do
    expect_no_offenses(<<~RUBY)
      Post.where(id: 1).where(id: 1)
    RUBY
  end

  it 'does not register an offense for safe navigation' do
    expect_no_offenses(<<~RUBY)
      Post.order(:rank)&.order(:rank)
    RUBY
  end
end
