# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::IndexNames, :config do
  context 'Rails 7.0', :rails70 do
    context 'when t.index has a custom name argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.0]
            def change
              change_table :users do |t|
                t.index [:email], name: 'index_custom_name'
              end
            end
          end
        RUBY
      end
    end

    context 'when add_index has a name argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.0]
            def change
              add_index :table, :column, name: 'index_custom_name'
            end
          end
        RUBY
      end
    end
  end

  context 'Rails 7.2', :rails72 do
    context 'when using an earlier migration version' do
      context 'when t.index has a custom name argument' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class ExampleMigration < ActiveRecord::Migration[7.0]
              def change
                change_table :users do |t|
                  t.index [:email], name: 'index_custom_name'
                end
              end
            end
          RUBY
        end
      end

      context 'when add_index has a name argument' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class ExampleMigration < ActiveRecord::Migration[7.0]
              def change
                add_index :table, :column, name: 'index_custom_name'
              end
            end
          RUBY
        end
      end
    end

    context 'when t.index has a custom name argument' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              change_table :users do |t|
                t.index [:email], name: 'index_custom_name'
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid specifying a custom name for common indexes. Let Rails handle the index name automatically.
              end
            end
          end
        RUBY
      end
    end

    context 'when t.index has no name argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              create_table :users do |t|
                t.index [:email]
              end
            end
          end
        RUBY
      end
    end

    context 'when add_index has no name argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              add_index :table, :column
            end
          end
        RUBY
      end
    end

    context 'when add_index is outside of a migration' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def change
            add_index :table, :column, name: 'index_custom_name'
          end
        RUBY
      end
    end

    context 'when t.index is outside of a migration' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def change
            create_table :users do |t|
              t.index [:email], name: 'index_custom_name'
            end
          end
        RUBY
      end
    end

    context 'when unrelated index method has a name argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          index :email, name: 'index_custom_name'
        RUBY
      end
    end

    context 'when t.index has a custom name old style hash argument' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              create_table :users do |t|
                t.index [:email], 'name' => 'index_custom_name'
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid specifying a custom name for common indexes. Let Rails handle the index name automatically.
              end
            end
          end
        RUBY
      end
    end

    context 'when t.index has multiple arguments and custom name' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              create_table :users do |t|
                t.index [:email], unique: true, name: 'index_custom_name'
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid specifying a custom name for common indexes. Let Rails handle the index name automatically.
              end
            end
          end
        RUBY
      end
    end

    context 'when t.index has a reason for a custom name and possibly distinct index on the same keys' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              create_table :users do |t|
                t.index [:email], include: :tags, name: 'index_custom_name'
              end
            end
          end
        RUBY
      end
    end

    context 'when correcting an offense' do
      it 'removes the custom name argument without removing following arguments' do
        expect_offense(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              create_table :users do |t|
                t.index [:email], name: 'index_custom_name', unique: true
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid specifying a custom name for common indexes. Let Rails handle the index name automatically.
              end
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              create_table :users do |t|
                t.index [:email], unique: true
              end
            end
          end
        RUBY
      end

      it 'removes only the name argument when there are other arguments and starts at name:' do
        expect_offense(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              create_table :users do |t|
                t.index [:email], unique: true, name: 'index_custom_name'
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid specifying a custom name for common indexes. Let Rails handle the index name automatically.
              end
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              create_table :users do |t|
                t.index [:email], unique: true
              end
            end
          end
        RUBY
      end

      it 'removes the name argument when it is the only keyword argument' do
        expect_offense(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              create_table :users do |t|
                t.index [:email], name: 'index_custom_name'
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid specifying a custom name for common indexes. Let Rails handle the index name automatically.
              end
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              create_table :users do |t|
                t.index [:email]
              end
            end
          end
        RUBY
      end

      it 'removes only the name => argument for classic hash style' do
        expect_offense(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              create_table :users do |t|
                t.index [:email], "name" => 'index_custom_name'
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid specifying a custom name for common indexes. Let Rails handle the index name automatically.
              end
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              create_table :users do |t|
                t.index [:email]
              end
            end
          end
        RUBY
      end
    end

    context 'when add_index has a name argument' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              add_index :table, :column, name: 'index_custom_name'
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid specifying a custom name for common indexes. Let Rails handle the index name automatically.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class ExampleMigration < ActiveRecord::Migration[7.2]
            def change
              add_index :table, :column
            end
          end
        RUBY
      end
    end
  end
end
