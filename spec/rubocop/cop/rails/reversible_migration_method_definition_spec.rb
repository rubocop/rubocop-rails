# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ReversibleMigrationMethodDefinition, :config do
  let(:config) do
    RuboCop::Config.new('AllCops' => { 'MigratedSchemaVersion' => '20240101010101' })
  end

  it 'does not register an offense with a change method' do
    expect_no_offenses(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[6.0]
        def change
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  it 'registers an offense with only an up method' do
    expect_offense(<<~RUBY, '20250101010101_some_migration.rb')
      class SomeMigration < ActiveRecord::Migration[6.0]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Migrations must contain either a `change` method, or both an `up` and a `down` method.

        def up
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  it 'does not register an offense with only an up method when migration file was migrated' do
    expect_no_offenses(<<~RUBY, '20190101010101_some_migration.rb')
      class SomeMigration < ActiveRecord::Migration[6.0]
        def up
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  it 'registers an offense with only an up method and `::` prefixed class name' do
    expect_offense(<<~RUBY, '20250101010101_some_migration.rb')
      class ::SomeMigration < ActiveRecord::Migration[6.0]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Migrations must contain either a `change` method, or both an `up` and a `down` method.

        def up
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  it 'registers an offense with only a down method' do
    expect_offense(<<~RUBY, '20250101010101_some_migration.rb')
      class SomeMigration < ActiveRecord::Migration[6.0]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Migrations must contain either a `change` method, or both an `up` and a `down` method.

        def down
          remove_column :users, :email
        end
      end
    RUBY
  end

  it 'does not register an offense with an up and a down method' do
    expect_no_offenses(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[6.0]
        def up
          add_column :users, :email, :text, null: false
        end

        def down
          remove_column :users, :email
        end
      end
    RUBY
  end

  it "registers an offense with a typo'd change method" do
    expect_offense(<<~RUBY, '20250101010101_some_migration.rb')
      class SomeMigration < ActiveRecord::Migration[6.0]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Migrations must contain either a `change` method, or both an `up` and a `down` method.
        def chance
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  it 'does not register an offense with helper methods' do
    expect_no_offenses(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[6.0]
        def change
          add_users_column :email, :text, null: false
        end

        private

        def add_users_column(column_name, null: false)
          add_column :users, column_name, type, null: null
        end
      end
    RUBY
  end

  it 'does not register an offense with an inner class' do
    expect_no_offenses(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[6.0]
        class Foo
        end

        def change
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  it 'registers offenses correctly with any migration class' do
    expect_offense(<<~RUBY, '20250101010101_some_migration.rb')
      class SomeMigration < ActiveRecord::Migration[5.2]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Migrations must contain either a `change` method, or both an `up` and a `down` method.
        def chance
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  it 'does not register offenses correctly with any migration class' do
    expect_no_offenses(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[5.2]
        def change
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  it 'does not register offenses correctly with any cbase migration class' do
    expect_no_offenses(<<~RUBY)
      class SomeMigration < ::ActiveRecord::Migration[5.2]
        def change
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  context 'when multiple databases' do
    it 'does not register an offense with a change method' do
      expect_no_offenses(<<~RUBY, 'db/animals_migrate/20211007000002_add_nice_to_animals.rb')
        class AddNiceToAnimals < ActiveRecord::Migration[7.0]
          def change
            add_column :animals, :nice, :boolean, default: true
          end
        end
      RUBY
    end

    it 'registers an offense with only an up method' do
      expect_offense(<<~RUBY, 'db/animals_migrate/20250101010101_add_nice_to_animals.rb')
        class AddNiceToAnimals < ActiveRecord::Migration[7.0]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Migrations must contain either a `change` method, or both an `up` and a `down` method.

          def up
            add_column :animals, :nice, :boolean, default: true
          end
        end
      RUBY
    end
  end
end
