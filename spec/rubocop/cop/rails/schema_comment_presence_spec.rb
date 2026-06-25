# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::SchemaCommentPresence, :config do
  let(:cop_config) do
    {
      'ExcludedTables' => %w[schema_migrations ar_internal_metadata],
      'ExcludedColumns' => %w[created_at updated_at]
    }
  end

  it 'registers an offense when the table has no comment' do
    expect_offense(<<~RUBY)
      create_table 'users', force: :cascade do |t|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing `comment:` on table `users`.
        t.string 'email', null: false, comment: 'Login identifier'
      end
    RUBY
  end

  it 'registers an offense when a column has no comment' do
    expect_offense(<<~RUBY)
      create_table 'users', comment: 'Application users', force: :cascade do |t|
        t.string 'email', null: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing `comment:` on column `users.email`.
      end
    RUBY
  end

  it 'registers offenses for both table and multiple columns' do
    expect_offense(<<~RUBY)
      create_table 'users' do |t|
      ^^^^^^^^^^^^^^^^^^^^ Missing `comment:` on table `users`.
        t.string 'email'
        ^^^^^^^^^^^^^^^^ Missing `comment:` on column `users.email`.
        t.integer 'age'
        ^^^^^^^^^^^^^^^ Missing `comment:` on column `users.age`.
      end
    RUBY
  end

  it 'does not register an offense when every table and column is commented' do
    expect_no_offenses(<<~RUBY)
      create_table 'users', comment: 'Application users', force: :cascade do |t|
        t.string 'email', null: false, comment: 'Login identifier'
        t.integer 'age', comment: 'User age in years'
      end
    RUBY
  end

  it 'ignores indexes, timestamps, foreign keys and check constraints' do
    expect_no_offenses(<<~RUBY)
      create_table 'users', comment: 'Application users' do |t|
        t.timestamps
        t.index ['email'], unique: true
        t.foreign_key 'accounts'
        t.check_constraint 'email IS NOT NULL'
      end
    RUBY
  end

  it 'skips columns listed in ExcludedColumns' do
    expect_no_offenses(<<~RUBY)
      create_table 'users', comment: 'Application users' do |t|
        t.datetime 'created_at', null: false
        t.datetime 'updated_at', null: false
      end
    RUBY
  end

  it 'skips tables listed in ExcludedTables' do
    expect_no_offenses(<<~RUBY)
      create_table 'schema_migrations', id: false do |t|
        t.string 'version', null: false
      end
    RUBY
  end

  it 'handles symbol table and column names' do
    expect_offense(<<~RUBY)
      create_table :users do |t|
      ^^^^^^^^^^^^^^^^^^^ Missing `comment:` on table `users`.
        t.string :email
        ^^^^^^^^^^^^^^^ Missing `comment:` on column `users.email`.
      end
    RUBY
  end

  it 'accepts the generic t.column form when commented' do
    expect_no_offenses(<<~RUBY)
      create_table 'events', comment: 'Domain events' do |t|
        t.column 'payload', :jsonb, null: false, comment: 'Serialized event body'
      end
    RUBY
  end
end
