# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TransactionExitStatement, :config do
  it 'registers an offense when `return` is used in transactions' do
    expect_offense(<<~RUBY)
      ApplicationRecord.transaction do
        return if user.active?
        ^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
      end
    RUBY
  end

  it 'registers an offense when `break` is used in transactions' do
    expect_offense(<<~RUBY)
      ApplicationRecord.transaction do
        break if user.active?
        ^^^^^ Exit statement `break` is not allowed. Use `raise` (rollback) or `next` (commit).
      end
    RUBY
  end

  it 'registers an offense when `throw` is used in transactions' do
    expect_offense(<<~RUBY)
      ApplicationRecord.transaction do
        throw if user.active?
        ^^^^^ Exit statement `throw` is not allowed. Use `raise` (rollback) or `next` (commit).
      end
    RUBY
  end

  it 'registers an offense when `return` is used in `with_lock` transactions' do
    expect_offense(<<~RUBY)
      user.with_lock do
        return if user.active?
        ^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
      end
    RUBY
  end

  it 'does not register an offense when `next` is used in transactions' do
    expect_no_offenses(<<~RUBY)
      ApplicationRecord.transaction do
        next if user.active?
      end
    RUBY
  end

  it 'does not register an offense when `raise` is used in transactions' do
    expect_no_offenses(<<~RUBY)
      ApplicationRecord.transaction do
        raise if user.active?
      end
    RUBY
  end

  it 'registers an offense when `return` is used in `loop` in transactions' do
    expect_offense(<<~RUBY)
      ApplicationRecord.transaction do
        loop do
          return if condition
          ^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
        end
      end
    RUBY
  end

  it 'registers an offense when `throw` is used in `loop` in transactions' do
    expect_offense(<<~RUBY)
      ApplicationRecord.transaction do
        loop do
          throw if condition
          ^^^^^ Exit statement `throw` is not allowed. Use `raise` (rollback) or `next` (commit).
        end
      end
    RUBY
  end

  it 'does not register an offense when `break` is used in `loop` in transactions' do
    expect_no_offenses(<<~RUBY)
      ApplicationRecord.transaction do
        loop do
          break if condition
        end
      end
    RUBY
  end

  it 'registers an offense when `return` is used in `rescue`' do
    expect_offense(<<~RUBY)
      ApplicationRecord.transaction do
      rescue
        return do_something
        ^^^^^^^^^^^^^^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
      end
    RUBY
  end

  it 'registers an officense when `return` is used outside of a `rescue`' do
    expect_offense(<<~RUBY)
      ApplicationRecord.transaction do
        return if user.active?
        ^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
      rescue
        pass
      end
    RUBY
  end

  it 'does not register an offense when transaction block is empty' do
    expect_no_offenses(<<~RUBY)
      ApplicationRecord.transaction do
      end
    RUBY
  end
end
