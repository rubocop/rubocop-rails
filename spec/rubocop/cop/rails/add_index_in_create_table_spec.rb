# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::AddIndexInCreateTable, :config do
  context 'when add_index is called after create_table for the same table' do
    it 'registers an offense for a single add_index' do
      expect_offense(<<~RUBY)
        def change
          create_table :users do |t|
            t.string :email
            t.timestamps
          end

          add_index :users, :email
          ^^^^^^^^^^^^^^^^^^^^^^^^ Add indexes using `t.index` inside `create_table` block instead of `add_index` after table creation.
        end
      RUBY
    end

    it 'registers an offense for multiple add_index calls' do
      expect_offense(<<~RUBY)
        def change
          create_table :users do |t|
            t.string :email
            t.string :name
            t.timestamps
          end

          add_index :users, :email
          ^^^^^^^^^^^^^^^^^^^^^^^^ Add indexes using `t.index` inside `create_table` block instead of `add_index` after table creation.
          add_index :users, :name
          ^^^^^^^^^^^^^^^^^^^^^^^ Add indexes using `t.index` inside `create_table` block instead of `add_index` after table creation.
        end
      RUBY
    end

    it 'registers an offense for add_index with options' do
      expect_offense(<<~RUBY)
        def change
          create_table :users do |t|
            t.string :email
            t.timestamps
          end

          add_index :users, :email, unique: true, algorithm: :concurrently
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add indexes using `t.index` inside `create_table` block instead of `add_index` after table creation.
        end
      RUBY
    end

    it 'registers an offense for composite index' do
      expect_offense(<<~RUBY)
        def change
          create_table :users do |t|
            t.string :first_name
            t.string :last_name
            t.timestamps
          end

          add_index :users, [:first_name, :last_name], unique: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add indexes using `t.index` inside `create_table` block instead of `add_index` after table creation.
        end
      RUBY
    end

    it 'registers offenses for complex migration with multiple indexes' do
      expect_offense(<<~RUBY)
        def change
          create_table :dedicated_advisor_tasks do |t|
            t.string :canonical_id, null: false
            t.string :identity_id, null: false
            t.string :task_type, null: false
            t.string :status, null: false, default: 'pending'
            t.datetime :completed_at
            t.datetime :verified_at
            t.string :verified_by

            t.timestamps
            t.datetime :deleted_at
          end

          add_index :dedicated_advisor_tasks, :canonical_id, algorithm: :concurrently
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add indexes using `t.index` inside `create_table` block instead of `add_index` after table creation.
          add_index :dedicated_advisor_tasks, :identity_id, algorithm: :concurrently
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add indexes using `t.index` inside `create_table` block instead of `add_index` after table creation.
          add_index :dedicated_advisor_tasks, :deleted_at, algorithm: :concurrently
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add indexes using `t.index` inside `create_table` block instead of `add_index` after table creation.
          add_index :dedicated_advisor_tasks, [:identity_id, :task_type],
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add indexes using `t.index` inside `create_table` block instead of `add_index` after table creation.
                    unique: true,
                    algorithm: :concurrently,
                    name: 'index_dedicated_advisor_tasks_on_identity_task_type'
        end
      RUBY
    end

    it 'registers an offense with numblock syntax' do
      expect_offense(<<~RUBY)
        def change
          create_table :users do
            _1.string :email
            _1.timestamps
          end

          add_index :users, :email
          ^^^^^^^^^^^^^^^^^^^^^^^^ Add indexes using `t.index` inside `create_table` block instead of `add_index` after table creation.
        end
      RUBY
    end
  end

  context 'when add_index is for a different table' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def change
          create_table :users do |t|
            t.string :email
            t.timestamps
          end

          add_index :posts, :user_id
        end
      RUBY
    end
  end

  context 'when using t.index inside create_table' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def change
          create_table :users do |t|
            t.string :email
            t.timestamps

            t.index :email
          end
        end
      RUBY
    end

    it 'does not register an offense for complex migration' do
      expect_no_offenses(<<~RUBY)
        def change
          create_table :dedicated_advisor_tasks do |t|
            t.string :canonical_id, null: false
            t.string :identity_id, null: false
            t.string :task_type, null: false
            t.string :status, null: false, default: 'pending'
            t.datetime :completed_at
            t.datetime :verified_at
            t.string :verified_by

            t.timestamps
            t.datetime :deleted_at

            t.index :canonical_id
            t.index :identity_id
            t.index :deleted_at
            t.index [:identity_id, :task_type], unique: true, name: 'index_dedicated_advisor_tasks_on_identity_task_type'
          end
        end
      RUBY
    end
  end

  context 'when add_index is called without a preceding create_table' do
    it 'does not register an offense for standalone add_index' do
      expect_no_offenses(<<~RUBY)
        def change
          add_index :users, :email
        end
      RUBY
    end

    it 'does not register an offense when add_index is in a separate migration' do
      expect_no_offenses(<<~RUBY)
        def change
          add_index :users, :email, algorithm: :concurrently
        end
      RUBY
    end
  end

  context 'when create_table has no block' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def change
          create_table :users
          add_index :users, :email
        end
      RUBY
    end
  end

  context 'when add_index comes before create_table' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def change
          add_index :users, :email

          create_table :users do |t|
            t.string :email
            t.timestamps
          end
        end
      RUBY
    end
  end

  context 'when in up/down methods' do
    it 'registers an offense in up method' do
      expect_offense(<<~RUBY)
        def up
          create_table :users do |t|
            t.string :email
            t.timestamps
          end

          add_index :users, :email
          ^^^^^^^^^^^^^^^^^^^^^^^^ Add indexes using `t.index` inside `create_table` block instead of `add_index` after table creation.
        end
      RUBY
    end
  end
end
