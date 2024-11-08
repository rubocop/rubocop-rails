# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ThreeStateBooleanColumn, :config do
  let(:config) do
    RuboCop::Config.new('AllCops' => { 'MigratedSchemaVersion' => '20240101010101' })
  end

  describe '#add_column' do
    it 'registers an offense with three state boolean' do
      expect_offense(<<~RUBY, '20250101010101_add_active_to_users.rb')
        add_column :users, :active, :boolean
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
        add_column :users, :active, :boolean, default: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
        add_column :users, :active, :boolean, default: true, null: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
      RUBY
    end

    it 'does not register an offense with three state boolean when migration file was migrated' do
      expect_no_offenses(<<~RUBY, '20190101010101_add_active_to_users.rb')
        add_column :users, :active, :boolean
        add_column :users, :active, :boolean, default: true
        add_column :users, :active, :boolean, default: true, null: true
      RUBY
    end

    it 'does not register an offense with non boolean' do
      expect_no_offenses(<<~RUBY)
        add_column :users, :email, :string
      RUBY
    end

    it 'does not register an offense with default and non null' do
      expect_no_offenses(<<~RUBY)
        add_column :users, :active, :boolean, default: true, null: false
      RUBY
    end

    it 'does not register an offense when using `#change_column_null`' do
      expect_no_offenses(<<~RUBY)
        def change
          add_column :users, :active, :boolean
          change_column_null :users, :active, false
        end
      RUBY
    end

    it 'does not register an offense when using `#change_column_null` with dynamic table' do
      expect_no_offenses(<<~RUBY)
        def change
          add_column table, :active, :boolean
          change_column_null table, :active, false
        end
      RUBY
    end

    it 'registers an offense when using `#change_column_null` for other table or column' do
      expect_offense(<<~RUBY, '20250101010101_add_active_to_users.rb')
        def change
          add_column :users, :active, :boolean
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
          change_column_null :users, :admin, false
          change_column_null :projects, :active, false
          change_column_null :users, :active, true
        end
      RUBY
    end
  end

  describe '#column' do
    it 'registers an offense with three state boolean' do
      expect_offense(<<~RUBY, '20250101010101_add_active_to_users.rb')
        t.column :active, :boolean
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
        t.column :active, :boolean, default: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
        t.column :active, :boolean, default: true, null: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
      RUBY
    end

    it 'does not register an offense with non boolean' do
      expect_no_offenses(<<~RUBY)
        t.column :email, :string
      RUBY
    end

    it 'does not register an offense with default and non null' do
      expect_no_offenses(<<~RUBY)
        t.column :active, :boolean, default: true, null: false
      RUBY
    end

    it 'does not register an offense when using `#change_column_null`' do
      expect_no_offenses(<<~RUBY)
        def change
          create_table(:users) do |t|
            t.column :active, :boolean
          end
          change_column_null :users, :active, false
        end
      RUBY
    end

    it 'does not register an offense when using `#change_column_null` with dynamic table' do
      expect_no_offenses(<<~RUBY)
        def change
          create_table(table) do |t|
            t.column :active, :boolean
          end
          change_column_null table, :active, false
        end
      RUBY
    end

    it 'registers an offense when using `#change_column_null` for other table or column' do
      expect_offense(<<~RUBY)
        def change
          create_table(:users) do |t|
            t.column :active, :boolean
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
          end
          change_column_null :users, :admin, false
          change_column_null :projects, :active, false
          change_column_null :users, :active, true
        end
      RUBY
    end
  end

  describe '#boolean' do
    it 'registers an offense for three state boolean' do
      expect_offense(<<~RUBY, '20250101010101_add_active_to_users.rb')
        t.boolean :active
        ^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
        t.boolean :active, default: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
        t.boolean :active, default: true, null: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
      RUBY
    end

    it 'does not register an offense with default and non null' do
      expect_no_offenses(<<~RUBY)
        t.boolean :active, default: true, null: false
      RUBY
    end

    it 'does not register an offense when using `t.boolean` in `drop_table`' do
      expect_no_offenses(<<~RUBY)
        def change
          drop_table(:users) do |t|
            t.boolean :active
          end
        end
      RUBY
    end

    it 'does not register an offense when using `#change_column_null`' do
      expect_no_offenses(<<~RUBY)
        def change
          create_table(:users) do |t|
            t.boolean :active
          end
          change_column_null :users, :active, false
        end
      RUBY
    end

    it 'does not register an offense when using `#change_column_null` with dynamic table' do
      expect_no_offenses(<<~RUBY)
        def change
          create_table(table) do |t|
            t.boolean :active
          end
          change_column_null table, :active, false
        end
      RUBY
    end

    it 'registers an offense when using `#change_column_null` for other table or column' do
      expect_offense(<<~RUBY, '20250101010101_add_active_to_users.rb')
        def change
          create_table(:users) do |t|
            t.boolean :active
            ^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
          end
          change_column_null :users, :admin, false
          change_column_null :projects, :active, false
          change_column_null :users, :active, true
        end
      RUBY
    end
  end
end
