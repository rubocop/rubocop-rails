# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::BulkChangeTable, :config do
  shared_examples 'offense' do
    it 'registers an offense when including combinable transformations' do
      expect_offense(<<~RUBY)
        def change
          change_table :users do |t|
          ^^^^^^^^^^^^^^^^^^^ You can combine alter queries using `bulk: true` options.
            t.string :name, null: false
            t.string :address, null: true
          end
        end
      RUBY
    end

    it 'registers an offense when including combinable alter methods' do
      expect_offense(<<~RUBY)
        def change
          add_column :users, :name, :string, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          remove_column :users, :nickname
        end
      RUBY
    end
  end

  shared_examples 'wrong arguments' do
    it 'does not register an offense for `change_table` with no block' do
      expect_no_offenses(<<~RUBY)
        def up
          change_table(:users)
        end
      RUBY
    end

    it 'does not register an offense for `change_table` with empty block' do
      expect_no_offenses(<<~RUBY)
        def up
          change_table(:users) do
          end
        end
      RUBY
    end
  end

  shared_examples 'no offense' do
    it 'does not register an offense when including combinable transformations' do
      expect_no_offenses(<<~RUBY)
        def change
          change_table :users do |t|
            t.string :name, null: false
            t.string :address, null: true
          end
        end
      RUBY
    end

    it 'does not register an offense when including combinable alter methods' do
      expect_no_offenses(<<~RUBY)
        def change
          add_column :users, :name, :string, null: false
          remove_column :users, :nickname
        end
      RUBY
    end

    it_behaves_like 'wrong arguments'
  end

  shared_examples 'offense for mysql' do
    it 'registers an offense when including combinable transformations' do
      expect_offense(<<~RUBY)
        def change
          change_table :users do |t|
          ^^^^^^^^^^^^^^^^^^^ You can combine alter queries using `bulk: true` options.
            t.index :name
            t.index :address
          end
        end
      RUBY
    end

    it 'registers an offense when including combinable alter methods' do
      expect_offense(<<~RUBY)
        def change
          remove_index :users, :name
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          remove_index :users, :address
        end
      RUBY
    end
  end

  shared_examples 'no offense for mysql' do
    it 'does not register an offense when including combinable transformations' do
      expect_no_offenses(<<~RUBY)
        def change
          change_table :users do |t|
            t.index :name
            t.index :address
          end
        end
      RUBY
    end

    it 'does not register an offense when including combinable alter methods' do
      expect_no_offenses(<<~RUBY)
        def change
          remove_index :users, :name
          remove_index :users, :address
        end
      RUBY
    end

    it_behaves_like 'wrong arguments'
  end

  shared_examples 'offense for postgresql' do
    it 'registers an offense when including combinable transformations' do
      expect_offense(<<~RUBY)
        def change
          change_table :users do |t|
          ^^^^^^^^^^^^^^^^^^^ You can combine alter queries using `bulk: true` options.
            t.change_default :name, 'unknown'
            t.change_default :address, nil
          end
        end
      RUBY
    end

    it 'registers an offense when including combinable alter methods' do
      expect_offense(<<~RUBY)
        def change
          change_column_default :users, :name, false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          change_column_default :users, :address, false
        end
      RUBY
    end

    it 'does not register an offense for `change_column_null`' do
      expect_no_offenses(<<~RUBY)
        def change
          change_column_null :users, :name, false
          change_column_null :users, :address, false
        end
      RUBY
    end
  end

  shared_examples 'no offense for postgresql' do
    it 'does not register an offense when including combinable transformations' do
      expect_no_offenses(<<~RUBY)
        def change
          change_table :users do |t|
            t.change_default :name, 'unknown'
            t.change_default :address, nil
          end
        end
      RUBY
    end

    it 'does not register an offense when including combinable alter methods' do
      expect_no_offenses(<<~RUBY)
        def change
          change_column_default :users, :name, false
          change_column_default :users, :address, false
        end
      RUBY

      expect_no_offenses(<<~RUBY)
        def change
          change_column_null :users, :name, false
          change_column_null :users, :address, false
        end
      RUBY
    end

    it_behaves_like 'wrong arguments'
  end

  it_behaves_like 'no offense'
  it_behaves_like 'no offense for mysql'
  it_behaves_like 'no offense for postgresql'

  context 'when database is MySQL' do
    let(:cop_config) do
      {
        'Database' => 'mysql',
        'Include' => ['*']
      }
    end

    it_behaves_like 'offense'
    it_behaves_like 'offense for mysql'
    it_behaves_like 'no offense for postgresql'

    it 'registers offenses when including combinable alter methods' do
      expect_offense(<<~RUBY)
        def change
          add_reference :users, :team
          add_column :users, :name, :string, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          remove_column :users, :nickname
          remove_column :users, :flag
          add_column :teams, :owner_name, :string, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :teams, bulk: true` to combine alter queries.
          add_column :teams, :member_count, :integer, null: false
          User.reset_column_information
          User.all.each do |user|
            user.refresh!
          end
          remove_column :users, :name
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          remove_column :users, :metadata
        end
      RUBY
    end

    it 'does not register an offense when including combinable transformations with `bulk: true`' do
      expect_no_offenses(<<~RUBY)
        def change
          change_table :users, bulk: true do |t|
            t.string :name, null: false
            t.string :address, null: true
          end
        end
      RUBY
    end

    it 'does not register an offense when including combinable transformations with `bulk: false`' do
      expect_no_offenses(<<~RUBY)
        def change
          change_table :users, bulk: false do |t|
            t.string :name, null: false
            t.string :address, null: true
          end
        end
      RUBY
    end

    it 'does not register an offense when including a combinable transformation' do
      expect_no_offenses(<<~RUBY)
        def change
          change_table :users do |t|
            t.belongs_to :team
            t.string :name, null: false
          end
        end
      RUBY
    end

    it 'does not register an offense when including a transformation' do
      expect_no_offenses(<<~RUBY)
        def change
          change_table :users do |t|
            t.string :name, null: false
          end
        end
      RUBY
    end

    it 'does not register an offense when transformations are inside of `if`' do
      expect_no_offenses(<<~RUBY)
        def change
          change_table :users do |t|
            if Rails.env.test?
              t.string :name, null: true
              t.string :address, null: true
            else
              t.string :name, null: false
              t.string :address, null: false
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when including transformations with block' do
      expect_no_offenses(<<~RUBY)
        def change
          reversible do |dir|
            change_table :users do |t|
              dir.up do
                t.string :name, null: false
                t.string :address, null: false
              end

              dir.down do
                t.remove :name
                t.remove :address
              end
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when the target of the alter method is another table' do
      expect_no_offenses(<<~RUBY)
        def change
          add_reference :users, :team
          add_column :users, :name, :string, null: false
          remove_column :teams, :owner_name
        end
      RUBY
    end

    it 'does not register an offense when including non-combinable alter method between' do
      expect_no_offenses(<<~RUBY)
        def change
          add_column :users, :name, :string, null: false
          add_reference :users, :team
          remove_column :users, :nickname
        end
      RUBY
    end

    it 'does not register an offense when including a block between' do
      expect_no_offenses(<<~RUBY)
        def change
          add_column :users, :name, :string, null: false
          User.find_each do |user|
            user.update(name: user.nickname)
          end
          remove_column :users, :nickname
        end
      RUBY
    end

    it 'does not register an offense when including a combinable alter method' do
      expect_no_offenses(<<~RUBY)
        def change
          add_reference :users, :team
          add_column :users, :name, :string, null: false
        end
      RUBY
    end

    it 'does not register an offense when including an alter method' do
      expect_no_offenses(<<~RUBY)
        def change
          add_column :users, :name, :string, null: false
        end
      RUBY
    end

    it 'does not register an offense when alter methods are inside of `if`' do
      expect_no_offenses(<<~RUBY)
        def change
          if Rails.env.test?
            add_reference :users, :team
            add_column :users, :name, :string, null: true
            remove_column :users, :nickname
          else
            add_reference :users, :team
            add_column :users, :name, :string, null: false
            remove_column :users, :nickname
          end
        end
      RUBY
    end

    it 'does not register an offense when using empty migration' do
      expect_no_offenses(<<~RUBY)
        class EmptyMigration < ActiveRecord::Migration[5.1]
          def change; end
        end
      RUBY
    end

    it 'registers an offense when using string as table name' do
      expect_offense(<<~RUBY)
        def change
          remove_index "users", :name
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          remove_index "users", :address
        end
      RUBY
    end

    it 'registers an offense when using mixed style table name' do
      expect_offense(<<~RUBY)
        def change
          remove_index "users", :name
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
          remove_index :users, :address
        end
      RUBY
    end

    it 'does not register an offense when using variables as table name' do
      expect_no_offenses(<<~RUBY)
        def change
          %w[owners members].each do |table|
            add_column table, :name, :string, null: false
          end
        end
      RUBY
    end

    it 'registers an offense for a single `t.remove` with multiple columns' do
      expect_offense(<<~RUBY)
        def change
          change_table :users do |t|
          ^^^^^^^^^^^^^^^^^^^ You can combine alter queries using `bulk: true` options.
            t.remove :name, :metadata
          end
        end
      RUBY
    end

    it 'does not register an offense for a single `t.remove` with one column' do
      expect_no_offenses(<<~RUBY)
        def change
          change_table :users do |t|
            t.remove :name
          end
        end
      RUBY
    end

    it 'registers an offense for a single `t.remove` with multiple columns and options' do
      expect_offense(<<~RUBY)
        def change
          change_table :users do |t|
          ^^^^^^^^^^^^^^^^^^^ You can combine alter queries using `bulk: true` options.
            t.remove :name, :metadata, type: :string
          end
        end
      RUBY
    end

    it 'does not register an offense for a single `t.remove` with one column and options' do
      expect_no_offenses(<<~RUBY)
        def change
          change_table :users do |t|
            t.remove :name, type: :string
          end
        end
      RUBY
    end

    it 'does not register an offense for multiple `change_column_null`' do
      expect_no_offenses(<<~RUBY)
        def change
          change_column_null :users, :name, false
          change_column_null :users, :address, false
        end
      RUBY
    end

    it 'does not register an offense for multiple `t.change_null`' do
      expect_no_offenses(<<~RUBY)
        def change
          change_table :users do |t|
            t.change_null :name, false
            t.change_null :address, false
          end
        end
      RUBY
    end

    context 'with methods wrapped in blocks' do
      it 'registers an offense when alter methods are wrapped in safety_assured block with do..end syntax' do
        expect_offense(<<~RUBY)
          def change
            safety_assured do
              add_column :users, :name, :string, null: false
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
              add_column :users, :email, :string
            end
          end
        RUBY
      end

      it 'registers an offense when alter methods are wrapped in safety_assured block with {} syntax' do
        expect_offense(<<~RUBY)
          def change
            safety_assured {
              add_column :users, :name, :string, null: false
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
              remove_column :users, :nickname
            }
          end
        RUBY
      end

      it 'registers an offense when alter methods are wrapped in safety_assured with mixed table operations' do
        expect_offense(<<~RUBY)
          def change
            safety_assured do
              add_column :users, :name, :string, null: false
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
              add_column :users, :email, :string
              remove_column :users, :nickname
              add_column :profiles, :bio, :text
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :profiles, bulk: true` to combine alter queries.
              add_column :profiles, :avatar_url, :string
            end
          end
        RUBY
      end

      it 'registers an offense when alter methods are wrapped in reversible block' do
        expect_offense(<<~RUBY)
          def change
            reversible do |dir|
              dir.up do
                add_column :users, :name, :string, null: false
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
                add_column :users, :email, :string
              end
              dir.down do
                remove_column :users, :email
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
                remove_column :users, :name
              end
            end
          end
        RUBY
      end

      it 'registers an offense when alter methods are wrapped in up_only block' do
        expect_offense(<<~RUBY)
          def change
            up_only do
              add_column :users, :name, :string, null: false
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
              add_column :users, :email, :string
              remove_column :users, :old_field
            end
          end
        RUBY
      end

      it 'registers an offense when alter methods are wrapped in custom block' do
        expect_offense(<<~RUBY)
          def change
            with_lock_retries do
              add_column :users, :name, :string, null: false
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
              add_column :users, :email, :string
            end
          end
        RUBY
      end

      it 'registers an offense when alter methods are wrapped in nested blocks' do
        expect_offense(<<~RUBY)
          def change
            safety_assured do
              with_lock_retries do
                add_column :users, :name, :string, null: false
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
                add_column :users, :email, :string
              end
            end
          end
        RUBY
      end

      it 'registers an offense when some alter methods are in blocks and others are not' do
        expect_offense(<<~RUBY)
          def change
            add_column :users, :first_name, :string
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
            safety_assured do
              add_column :users, :last_name, :string
            end
            add_column :users, :email, :string
          end
        RUBY
      end

      it 'registers an offense when alter methods are wrapped in transaction block' do
        expect_offense(<<~RUBY)
          def change
            transaction do
              add_column :users, :name, :string, null: false
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
              add_column :users, :email, :string
            end
          end
        RUBY
      end

      it 'registers an offense when alter methods are wrapped in disable_ddl_transaction block' do
        expect_offense(<<~RUBY)
          def change
            disable_ddl_transaction!
            
            safety_assured do
              add_index :users, :email, algorithm: :concurrently
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
              add_index :users, :name, algorithm: :concurrently
            end
          end
        RUBY
      end

      it 'does not register an offense when alter methods target different tables in the same block' do
        expect_no_offenses(<<~RUBY)
          def change
            safety_assured do
              add_column :users, :name, :string
              add_column :profiles, :bio, :text
            end
          end
        RUBY
      end

      it 'does not register an offense when only one alter method is in a block' do
        expect_no_offenses(<<~RUBY)
          def change
            safety_assured do
              add_column :users, :name, :string
            end
          end
        RUBY
      end

      it 'does not register an offense when blocks contain non-combinable operations' do
        expect_no_offenses(<<~RUBY)
          def change
            safety_assured do
              add_column :users, :name, :string
              add_reference :users, :team
              remove_column :users, :old_field
            end
          end
        RUBY
      end

      it 'registers an offense when change_table transformations are wrapped in safety_assured' do
        expect_offense(<<~RUBY)
          def change
            safety_assured do
              change_table :users do |t|
              ^^^^^^^^^^^^^^^^^^^ You can combine alter queries using `bulk: true` options.
                t.string :name, null: false
                t.string :email
              end
            end
          end
        RUBY
      end

      it 'does not register an offense when change_table with bulk: true is wrapped in safety_assured' do
        expect_no_offenses(<<~RUBY)
          def change
            safety_assured do
              change_table :users, bulk: true do |t|
                t.string :name, null: false
                t.string :email
              end
            end
          end
        RUBY
      end
    end
  end

  context 'when database is PostgreSQL' do
    let(:cop_config) do
      {
        'Database' => 'postgresql',
        'Include' => ['*']
      }
    end

    context 'with Rails 5.2', :rails52 do
      it_behaves_like 'offense'
      it_behaves_like 'no offense for mysql'
      it_behaves_like 'offense for postgresql'

      it 'does not register an offense for multiple `change_column_null`' do
        expect_no_offenses(<<~RUBY)
          def change
            change_column_null :users, :name, false
            change_column_null :users, :address, false
          end
        RUBY
      end

      it 'does not register an offense for multiple `t.change_null`' do
        expect_no_offenses(<<~RUBY)
          def change
            change_table :users do |t|
              t.change_null :name, false
              t.change_null :address, false
            end
          end
        RUBY
      end
    end

    context 'with Rails 5.1', :rails51 do
      it_behaves_like 'no offense'
      it_behaves_like 'no offense for mysql'
      it_behaves_like 'no offense for postgresql'
    end

    context 'with Rails 6.1', :rails61 do
      it 'registers an offense for multiple `change_column_null`' do
        expect_offense(<<~RUBY)
          def change
            change_column_null :users, :name, false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You can use `change_table :users, bulk: true` to combine alter queries.
            change_column_null :users, :address, false
          end
        RUBY
      end

      it 'registers an offense for multiple `t.change_null`' do
        expect_offense(<<~RUBY)
          def change
            change_table :users do |t|
            ^^^^^^^^^^^^^^^^^^^ You can combine alter queries using `bulk: true` options.
              t.change_null :name, false
              t.change_null :address, false
            end
          end
        RUBY
      end

      it 'does not register an offense for multiple `t.change_null` with `bulk: true`' do
        expect_no_offenses(<<~RUBY)
          def change
            change_table :users, bulk: true do |t|
              t.change_null :name, false
              t.change_null :address, false
            end
          end
        RUBY
      end
    end
  end

  context 'when `database.yml` is exists' do
    let(:yaml) { nil }

    before do
      allow(File).to receive(:exist?).with('config/database.yml').and_return(true)
      if YAML.respond_to?(:unsafe_load_file)
        allow(YAML).to receive(:unsafe_load_file).with('config/database.yml').and_return(yaml)
      else
        allow(YAML).to receive(:load_file).with('config/database.yml').and_return(yaml)
      end
    end

    context 'mysql2' do
      context 'with top-level adapter configuration' do
        let(:yaml) do
          {
            'development' => {
              'adapter' => 'mysql2'
            }
          }
        end

        it_behaves_like 'offense for mysql'
      end

      context 'with nested adapter configuration' do
        let(:yaml) do
          {
            'development' => {
              'primary' => {
                'adapter' => 'mysql2'
              }
            }
          }
        end

        it_behaves_like 'offense for mysql'
      end
    end

    context 'trilogy' do
      context 'with top-level adapter configuration' do
        let(:yaml) do
          {
            'development' => {
              'adapter' => 'trilogy'
            }
          }
        end

        it_behaves_like 'offense for mysql'
      end

      context 'with nested adapter configuration' do
        let(:yaml) do
          {
            'development' => {
              'primary' => {
                'adapter' => 'trilogy'
              }
            }
          }
        end

        it_behaves_like 'offense for mysql'
      end
    end

    context 'postgresql' do
      context 'with top-level adapter configuration' do
        let(:yaml) do
          {
            'development' => {
              'adapter' => 'postgresql'
            }
          }
        end

        context 'with Rails 5.2', :rails52 do
          it_behaves_like 'offense for postgresql'
        end

        context 'with Rails 5.1', :rails51 do
          it_behaves_like 'no offense for postgresql'
        end
      end

      context 'with nested adapter configuration' do
        let(:yaml) do
          {
            'development' => {
              'primary' => {
                'adapter' => 'postgresql'
              }
            }
          }
        end

        context 'with Rails 5.2', :rails52 do
          it_behaves_like 'offense for postgresql'
        end

        context 'with Rails 5.1', :rails51 do
          it_behaves_like 'no offense for postgresql'
        end
      end
    end

    context 'postgis' do
      context 'with top-level adapter configuration' do
        let(:yaml) do
          {
            'development' => {
              'adapter' => 'postgis'
            }
          }
        end

        context 'with Rails 5.2', :rails52 do
          it_behaves_like 'offense for postgresql'
        end

        context 'with Rails 5.1', :rails51 do
          it_behaves_like 'no offense for postgresql'
        end
      end

      context 'with nested adapter configuration' do
        let(:yaml) do
          {
            'development' => {
              'primary' => {
                'adapter' => 'postgis'
              }
            }
          }
        end

        context 'with Rails 5.2', :rails52 do
          it_behaves_like 'offense for postgresql'
        end

        context 'with Rails 5.1', :rails51 do
          it_behaves_like 'no offense for postgresql'
        end
      end
    end

    context 'invalid (e.g. ERB)' do
      before do
        allow(YAML).to receive(:load_file).with('config/database.yml') do
          YAML.parse('pool: <%= Rails.env.production? ? 10 : 5 %>')
        end
      end

      it_behaves_like 'no offense'
    end
  end

  context 'when `DATABASE_URL` is set' do
    before do
      stub_const('ENV', 'DATABASE_URL' => database_url)
    end

    context 'mysql2' do
      let(:database_url) { 'mysql2://localhost/my_database' }

      it_behaves_like 'offense for mysql'
    end

    context 'trilogy' do
      let(:database_url) { 'trilogy://localhost/my_database' }

      it_behaves_like 'offense for mysql'
    end

    context 'postgres' do
      let(:database_url) { 'postgres://localhost/my_database' }

      context 'with Rails 5.2', :rails52 do
        it_behaves_like 'offense for postgresql'
      end

      context 'with Rails 5.1', :rails51 do
        it_behaves_like 'no offense for postgresql'
      end
    end

    context 'postgresql' do
      let(:database_url) { 'postgresql://localhost/my_database' }

      context 'with Rails 5.2', :rails52 do
        it_behaves_like 'offense for postgresql'
      end

      context 'with Rails 5.1', :rails51 do
        it_behaves_like 'no offense for postgresql'
      end
    end

    context 'unsupported (e.g. sqlserver)' do
      let(:database_url) { 'sqlserver://localhost/my_database' }

      it_behaves_like 'no offense'
    end
  end
end
