# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::SchemaComment, :config do
  let(:config) do
    RuboCop::Config.new('AllCops' => { 'MigratedSchemaVersion' => '20240101010101' })
  end

  context 'when send add_column' do
    it 'registers an offense when `add_column` has no `comment` option' do
      expect_offense(<<~RUBY, '20250101010101_add_column_to_table.rb')
        add_column :table, :column, :integer
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ New database column without `comment`.
      RUBY
    end

    it 'does not register an offense when `add_column` has no `comment` option when migration file was migrated' do
      expect_no_offenses(<<~RUBY, '20190101010101_add_column_to_table.rb')
        add_column :table, :column, :integer
      RUBY
    end

    it 'registers an offense when `add_column` has no `comment` option, but other options' do
      expect_offense(<<~RUBY, '20250101010101_add_column_to_table.rb')
        add_column :table, :column, :integer, default: 0
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ New database column without `comment`.
      RUBY
    end

    it 'registers an offense when `add_column` has a nil `comment` option' do
      expect_offense(<<~RUBY, '20250101010101_add_column_to_table.rb')
        add_column :table, :column, :integer, comment: nil
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ New database column without `comment`.
      RUBY
    end

    it 'registers an offense when `add_column` has an empty `comment` option' do
      expect_offense(<<~RUBY, '20250101010101_add_column_to_table.rb')
        add_column :table, :column, :integer, comment: ''
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ New database column without `comment`.
      RUBY
    end

    it 'does not register an offense when `add_column` has `comment` option' do
      expect_no_offenses(<<~RUBY)
        add_column :table, :column, :integer, comment: 'An integer field'
      RUBY
    end

    it 'does not register an offense when `add_column` has `comment` option among other options' do
      expect_no_offenses(<<~RUBY)
        add_column :table, :column, :integer, null: false, comment: 'An integer field', default: 0
      RUBY
    end
  end

  context 'when send create_table' do
    it 'registers an offense when `create_table` has no `comment` option' do
      expect_offense(<<~RUBY, '20250101010101_create_users.rb')
        create_table :users do |t|
        ^^^^^^^^^^^^^^^^^^^ New database table without `comment`.
        end
      RUBY
    end

    it 'registers an offense when `create_table` has a nil `comment` option' do
      expect_offense(<<~RUBY, '20250101010101_create_users.rb')
        create_table :users, comment: nil do |t|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ New database table without `comment`.
        end
      RUBY
    end

    it 'registers an offense when `create_table` has a empty `comment` option' do
      expect_offense(<<~RUBY, '20250101010101_create_users.rb')
        create_table :users, comment: '' do |t|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ New database table without `comment`.

        end
      RUBY
    end

    it 'registers an offense when `t.column` has no `comment` option' do
      expect_offense(<<~RUBY, '20250101010101_create_users.rb')
        create_table :users, comment: 'Table' do |t|
          t.column :column, :integer
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ New database column without `comment`.
        end
      RUBY
    end

    it 'registers an offense when `t.integer` has no `comment` option' do
      expect_offense(<<~RUBY, '20250101010101_create_users.rb')
        create_table :users, comment: 'Table' do |t|
          t.integer :column
          ^^^^^^^^^^^^^^^^^ New database column without `comment`.
        end
      RUBY
    end

    it 'registers two offenses when two `t.column` have no `comment` option' do
      expect_offense(<<~RUBY, '20250101010101_create_users.rb')
        create_table :users, comment: 'Table' do |t|
          t.column :column1, :integer
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ New database column without `comment`.
          t.column :column2, :integer
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ New database column without `comment`.
        end
      RUBY
    end

    it 'registers two offenses when two `t.integer` have no `comment` option' do
      expect_offense(<<~RUBY, '20250101010101_create_users.rb')
        create_table :users, comment: 'Table' do |t|
          t.integer :column1
          ^^^^^^^^^^^^^^^^^^ New database column without `comment`.
          t.integer :column2
          ^^^^^^^^^^^^^^^^^^ New database column without `comment`.
        end
      RUBY
    end

    it 'does not register an offense when `t.column` has `comment` option' do
      expect_no_offenses(<<~RUBY)
        create_table :users, comment: 'Table' do |t|
          t.column :column, :integer, comment: 'I am a column'
        end
      RUBY
    end

    it 'does not register an offense when `t.column` has `comment` option among other options' do
      expect_no_offenses(<<~RUBY)
        create_table :users, comment: 'Table' do |t|
          t.column :column, :integer, default: nil, comment: 'I am a column', null: true
        end
      RUBY
    end

    it 'does not register an offense when `t.integer` has `comment` option among other options' do
      expect_no_offenses(<<~RUBY)
        create_table :users, comment: 'Table' do |t|
          t.integer :column, default: nil, comment: 'I am a column', null: true
        end
      RUBY
    end
  end
end
