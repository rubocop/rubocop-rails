# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ThreeStateBooleanColumn, :config do
  describe '#add_column' do
    it 'registers an offense with three state boolean' do
      expect_offense(<<~RUBY)
        add_column :users, :active, :boolean
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
        add_column :users, :active, :boolean, default: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
        add_column :users, :active, :boolean, default: true, null: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
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

    it 'registers an offense when using `#change_column_null` for other table or column' do
      expect_offense(<<~RUBY)
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
      expect_offense(<<~RUBY)
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
      expect_offense(<<~RUBY)
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

    it 'registers an offense when using `#change_column_null` for other table or column' do
      expect_offense(<<~RUBY)
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

  context 'with StartAfter config' do
    let(:cop_config) do
      { 'StartAfter' => '20230415000000' }
    end

    it 'does not register an offense for old files' do
      expect_no_offenses(<<~RUBY, 'db/migrate/20230414000000_create_users.rb')
        class CreateUsers < ActiveRecord::Migration[7.0]
          create_table(:users) do |t|
            t.boolean :active
          end
        end
      RUBY
    end

    it 'registers an offense for new files' do
      expect_offense(<<~RUBY, 'db/migrate/20230415000000_create_users.rb')
        class CreateUsers < ActiveRecord::Migration[7.0]
          create_table(:users) do |t|
            t.boolean :active
            ^^^^^^^^^^^^^^^^^ Boolean columns should always have a default value and a `NOT NULL` constraint.
          end
        end
      RUBY
    end
  end
end
