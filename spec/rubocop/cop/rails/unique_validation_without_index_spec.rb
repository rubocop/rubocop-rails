# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::UniqueValidationWithoutIndex, :config do
  subject(:cop) { described_class.new(config) }

  context 'without db/schema.rb' do
    it 'does nothing' do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          validates :account, uniqueness: true
        end
      RUBY
    end
  end

  context 'with db/schema.rb' do
    let(:schema_path) do
      f = Tempfile.create('rubocop-rails-UniqueValidationWithoutIndex-test-')
      f.close
      Pathname(f.path)
    end

    before do
      RuboCop::Rails::SchemaLoader.reset!
      schema_path.write(schema)
      allow(RuboCop::Rails::SchemaLoader).to receive(:db_schema_path)
        .and_return(schema_path)
    end

    after do
      RuboCop::Rails::SchemaLoader.reset!
      schema_path.unlink
    end

    context 'when the table does not have any indices' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "users", force: :cascade do |t|
            t.string "account", null: false
            # t.index ["account"], name: "index_users_on_account"
          end
        end
      RUBY

      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class User
            validates :account, uniqueness: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should be with a unique index.
          end
        RUBY
      end
    end

    context 'when the table has an index but it is not unique' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "users", force: :cascade do |t|
            t.string "account", null: false
            t.index ["account"], name: "index_users_on_account"
          end
        end
      RUBY

      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class User
            validates :account, uniqueness: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should be with a unique index.
          end
        RUBY
      end
    end

    context 'when the table has an index but it is not unique' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "users", force: :cascade do |t|
            t.string "account", null: false
            t.index ["account"], name: "index_users_on_account"
          end
        end
      RUBY

      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class User
            validates :account, uniqueness: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should be with a unique index.
          end
        RUBY
      end
    end

    context 'with a unique index' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "users", force: :cascade do |t|
            t.string "account", null: false
            t.index ["account"], name: "index_users_on_account", unique: true
          end
        end
      RUBY

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class User
            validates :account, uniqueness: true
          end
        RUBY
      end
    end

    context 'when the validation is for two columns' do
      context 'without proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "written_articles", force: :cascade do |t|
              t.bitint "user_id", null: false
              t.bitint "article_id", null: false
              t.index ["user_id"], name: "idx_uid", unique: true
              t.index ["article_id"], name: "idx_aid", unique: true
            end
          end
        RUBY

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class WrittenArticles
              validates :user_id, uniqueness: { scope: :article_id }
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should be with a unique index.
            end
          RUBY
        end
      end

      context 'with proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "written_articles", force: :cascade do |t|
              t.bitint "user_id", null: false
              t.bitint "article_id", null: false
              t.index ["user_id", "article_id"], name: "idx_uid_aid", unique: true
            end
          end
        RUBY

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class WrittenArticles
              validates :user_id, uniqueness: { scope: :article_id }
            end
          RUBY
        end
      end
    end

    context 'when the validation is for three columns' do
      context 'without proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "written_articles", force: :cascade do |t|
              t.bitint "a_id", null: false
              t.bitint "b_id", null: false
              t.bitint "c_id", null: false
              t.index ["a_id"], name: "idx_aid", unique: true
              t.index ["b_id"], name: "idx_bid", unique: true
              t.index ["c_id"], name: "idx_cid", unique: true
            end
          end
        RUBY

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class WrittenArticles
              validates :a_id, uniqueness: { scope: [:b_id, :c_id] }
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should be with a unique index.
            end
          RUBY
        end
      end

      context 'with proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "written_articles", force: :cascade do |t|
              t.bitint "a_id", null: false
              t.bitint "b_id", null: false
              t.bitint "c_id", null: false
              t.index ["a_id", "b_id", "c_id"], name: "idx_ids", unique: true
            end
          end
        RUBY

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class WrittenArticles
              validates :a_id, uniqueness: { scope: [:b_id, :c_id] }
            end
          RUBY
        end
      end
    end

    context 'when the validation is for a relation with _id column' do
      context 'without proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bitint "user_id", null: false
              t.index ["user_id"], name: "idx_user_id"
            end
          end
        RUBY

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class Article
              belongs_to :user
              validates :user, uniqueness: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should be with a unique index.
            end
          RUBY
        end
      end

      context 'with proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bitint "user_id", null: false
              t.index ["user_id"], name: "idx_user_id", unique: true
            end
          end
        RUBY

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class Article
              belongs_to :user
              validates :user, uniqueness: true
            end
          RUBY
        end
      end

      context 'with an if condition on the validation' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bitint "user_id", null: false
            end
          end
        RUBY

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class Article
              belongs_to :user
              validates :user, uniqueness: true, if: -> { false }
            end
          RUBY
        end
      end

      context 'with an unless condition on the validation' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bitint "user_id", null: false
            end
          end
        RUBY

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class Article
              belongs_to :user
              validates :user, uniqueness: true, unless: -> { true }
            end
          RUBY
        end
      end

      context 'without column definition' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bitint "member_id", null: false
              t.index ["user_id"], name: "idx_user_id", unique: true
            end
          end
        RUBY

        it 'ignores it' do
          expect_no_offenses(<<~RUBY)
            class Article
              belongs_to :user
              validates :user, uniqueness: true
            end
          RUBY
        end
      end
    end

    context 'when the validation is for a relation with foreign_key: option' do
      context 'without proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bitint "user_id", null: false
              t.index ["user_id"], name: "idx_user_id"
            end
          end
        RUBY

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class Article
              belongs_to :member, foreign_key: :user_id
              validates :member, uniqueness: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should be with a unique index.
            end
          RUBY
        end
      end

      context 'with proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bitint "user_id", null: false
              t.index ["user_id"], name: "idx_user_id", unique: true
            end
          end
        RUBY

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class Article
              belongs_to :member, foreign_key: :user_id
              validates :member, uniqueness: true
            end
          RUBY
        end
      end

      context 'without column definition' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bitint "foo_id", null: false
              t.index ["user_id"], name: "idx_user_id", unique: true
            end
          end
        RUBY

        it 'ignores it' do
          expect_no_offenses(<<~RUBY)
            class Article
              belongs_to :member, foreign_key: :user_id
              validates :member, uniqueness: true
            end
          RUBY
        end
      end
    end

    context 'with ActiveRecord::Base.table_name=' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "members", force: :cascade do |t|
            t.string "account", null: false
          end
        end
      RUBY

      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class User
            self.table_name = 'members'
            validates :account, uniqueness: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should be with a unique index.
          end
        RUBY
      end
    end

    context 'with nested class' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "admin_users", force: :cascade do |t|
            t.string "account", null: false
          end
        end
      RUBY

      it 'registers an offense' do
        expect_offense(<<~RUBY)
          module Admin
            class User
              validates :account, uniqueness: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should be with a unique index.
            end
          end
        RUBY
      end
    end

    context 'with expression indexes' do
      context 'when column name is included in expression index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table 'emails', force: :cascade do |t|
              t.string 'address', null: false
              t.index 'lower(address)', name: 'index_emails_on_lower_address', unique: true
            end
          end
        RUBY

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class Email < ApplicationRecord
              validates :address, presence: true, uniqueness: { case_sensitive: false }, email: true
            end
          RUBY
        end
      end

      context 'when column name is not included in expression index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table 'emails', force: :cascade do |t|
              t.string 'address', null: false
              t.index 'lower(unexpected_column_name)', name: 'index_emails_on_lower_address', unique: true
            end
          end
        RUBY

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class Email < ApplicationRecord
              validates :address, presence: true, uniqueness: { case_sensitive: false }, email: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should be with a unique index.
            end
          RUBY
        end
      end
    end
  end
end
