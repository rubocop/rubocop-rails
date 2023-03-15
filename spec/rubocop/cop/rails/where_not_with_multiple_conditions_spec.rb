# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::WhereNotWithMultipleConditions, :config do
  it 'does not register an offense for where.not with one condition' do
    expect_no_offenses(<<~RUBY)
      User.where.not(trashed: true)
    RUBY
  end

  it 'registers an offense for where.not with multiple conditions' do
    expect_offense(<<~RUBY)
      User.where.not(trashed: true, role: 'admin')
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a SQL statement instead of `where.not` with multiple conditions.
    RUBY
  end

  it 'registers an offense for where.not with nested multiple conditions' do
    expect_offense(<<~RUBY)
      User.joins(:posts).where.not({ posts: { trashed: true, title: 'Rails' } })
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a SQL statement instead of `where.not` with multiple conditions.
    RUBY
  end

  it 'does not register an offense for where with multiple conditions' do
    expect_no_offenses(<<~RUBY)
      User.where(trashed: false, role: 'admin')
    RUBY
  end

  it 'does not register an offense for where.not with a SQL string' do
    expect_no_offenses(<<~RUBY)
      User.where.not('trashed = ? OR role = ?', true, 'admin')
    RUBY
  end

  it 'does not register an offense for where.not with one array condition' do
    expect_no_offenses(<<~RUBY)
      User.where.not(role: ['moderator', 'admin'])
    RUBY
  end

  it 'does not register an offense for chained where.not' do
    expect_no_offenses(<<~RUBY)
      User.where.not(trashed: true).where.not(role: 'admin')
    RUBY
  end

  it 'does not register an offense for `where.not` with empty hash literal' do
    expect_no_offenses(<<~RUBY)
      User.where.not(data: {})
    RUBY
  end

  it 'does not register an offense when using `where.not.lt(condition)` as a Mongoid API' do
    expect_no_offenses(<<~RUBY)
      User.where.not.lt(condition)
    RUBY
  end
end
