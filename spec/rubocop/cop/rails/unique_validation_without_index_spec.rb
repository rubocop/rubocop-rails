# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::UniqueValidationWithoutIndex, :config do
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
    include_context 'with SchemaLoader'

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
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should have a unique index on the database column.
          end
        RUBY
      end

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class User
            validates :account, uniqueness: false
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
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should have a unique index on the database column.
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

    context 'with a unique index and `check_constraint` that has `nil` first argument' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "users", force: :cascade do |t|
            t.string "account", null: false
            t.index ["account"], name: "index_users_on_account", unique: true
            t.check_constraint nil, 'expression', name: "constraint_name"
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
              t.bigint "user_id", null: false
              t.bigint "article_id", null: false
              t.index ["user_id"], name: "idx_uid", unique: true
              t.index ["article_id"], name: "idx_aid", unique: true
            end
          end
        RUBY

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class WrittenArticles
              validates :user_id, uniqueness: { scope: :article_id }
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should have a unique index on the database column.
            end
          RUBY
        end
      end

      context 'with proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "written_articles", force: :cascade do |t|
              t.bigint "user_id", null: false
              t.bigint "article_id", null: false
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

    context 'when the validation is for a polymorphic association' do
      context 'without proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "written_articles", force: :cascade do |t|
              t.string "title", null: false
              t.string "author_type", null: false
              t.bigint "author_id", null: false
              t.index ["title", "author_id"], name: "idx_aid", unique: true
            end
          end
        RUBY

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class WrittenArticles
              belongs_to :author, polymorphic: true
              validates :title, uniqueness: { scope: :author }
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should have a unique index on the database column.
            end
          RUBY
        end
      end

      context 'with proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "written_articles", force: :cascade do |t|
              t.string "title", null: false
              t.string "author_type", null: false
              t.bigint "author_id", null: false
              t.index ["title", "author_id", "author_type"], name: "idx_aid", unique: true
            end
          end
        RUBY

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class WrittenArticles
              belongs_to :author, polymorphic: true
              validates :title, uniqueness: { scope: :author }
            end
          RUBY
        end
      end

      context 'when `polymorphic: false`' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "written_articles", force: :cascade do |t|
              t.string "title", null: false
              t.string "author_type", null: false
              t.bigint "author_id", null: false
              t.index ["title", "author_id"], name: "idx_aid", unique: true
            end
          end
        RUBY

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class WrittenArticles
              belongs_to :author, polymorphic: false
              validates :title, uniqueness: { scope: :author }
            end
          RUBY
        end
      end

      context 'when `polymorphic` option is not specified' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "written_articles", force: :cascade do |t|
              t.string "title", null: false
              t.string "author_type", null: false
              t.bigint "author_id", null: false
              t.index ["title", "author_id"], name: "idx_aid", unique: true
            end
          end
        RUBY

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class WrittenArticles
              belongs_to :author
              validates :title, uniqueness: { scope: :author }
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
              t.bigint "a_id", null: false
              t.bigint "b_id", null: false
              t.bigint "c_id", null: false
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
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should have a unique index on the database column.
            end
          RUBY
        end
      end

      context 'with proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "written_articles", force: :cascade do |t|
              t.bigint "a_id", null: false
              t.bigint "b_id", null: false
              t.bigint "c_id", null: false
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

        context 'when scope is frozen' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              class WrittenArticles
                validates :a_id, uniqueness: { scope: [:b_id, :c_id].freeze }
              end
            RUBY
          end
        end
      end
    end

    context 'when the validation is for a relation with _id column' do
      context 'without proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bigint "user_id", null: false
              t.index ["user_id"], name: "idx_user_id"
            end
          end
        RUBY

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class Article
              belongs_to :user
              validates :user, uniqueness: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should have a unique index on the database column.
            end
          RUBY
        end
      end

      context 'with proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bigint "user_id", null: false
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

      context 'without the proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bigint "user_id", null: false
            end
          end
        RUBY

        it 'does not register an offense with an if condition on validates' do
          expect_no_offenses(<<~RUBY)
            class Article
              belongs_to :user
              validates :user, uniqueness: true, if: -> { false }
            end
          RUBY
        end

        it 'does not register an offense with an unless condition on validates' do
          expect_no_offenses(<<~RUBY)
            class Article
              belongs_to :user
              validates :user, uniqueness: true, unless: -> { true }
            end
          RUBY
        end

        it 'does not register an offense with an if condition on the specific validator' do
          expect_no_offenses(<<~RUBY)
            class Article
              belongs_to :user
              validates :user, uniqueness: { if: -> { false } }
            end
          RUBY
        end

        it 'does not register an offense with an unless condition on the specific validator' do
          expect_no_offenses(<<~RUBY)
            class Article
              belongs_to :user
              validates :user, uniqueness: { unless: -> { false } }
            end
          RUBY
        end

        it 'does not register an offense with a conditions option on the specific validator' do
          expect_no_offenses(<<~RUBY)
            class Article
              belongs_to :user
              enum :status, [:draft, :published]
              validates :user, uniqueness: { conditions: -> { published } }
            end
          RUBY
        end
      end

      context 'without column definition' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bigint "member_id", null: false
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

    context 'when a table has no column definition' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "users", force: :cascade do |t|
          end
        end
      RUBY

      it 'ignores it' do
        expect_no_offenses(<<~RUBY)
          class User
            validates :account, uniqueness: true
          end
        RUBY
      end
    end

    context 'when the validation is for a relation with foreign_key: option' do
      context 'without proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bigint "user_id", null: false
              t.index ["user_id"], name: "idx_user_id"
            end
          end
        RUBY

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class Article
              belongs_to :member, foreign_key: :user_id
              validates :member, uniqueness: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should have a unique index on the database column.
            end
          RUBY
        end
      end

      context 'with proper index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "articles", force: :cascade do |t|
              t.bigint "user_id", null: false
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
              t.bigint "foo_id", null: false
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
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should have a unique index on the database column.
          end
        RUBY
      end
    end

    context 'with namespaced model' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "admin_users", force: :cascade do |t|
            t.string "account", null: false
          end
        end
      RUBY

      it 'registers an offense for nested class' do
        expect_offense(<<~RUBY)
          module Admin
            class User
              validates :account, uniqueness: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should have a unique index on the database column.
            end
          end
        RUBY
      end

      it 'registers an offense for compact styled class' do
        expect_offense(<<~RUBY)
          class Admin::User
            validates :account, uniqueness: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should have a unique index on the database column.
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
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should have a unique index on the database column.
            end
          RUBY
        end
      end
    end

    context 'when db/schema.rb has been dumped using `add_index` for index' do
      context 'when the table does not have any indices' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "users", force: :cascade do |t|
              t.string "account", null: false
            end
            add_index "users", "account", name: "index_users_on_account"
          end
        RUBY

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class User
              validates :account, uniqueness: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Uniqueness validation should have a unique index on the database column.
            end
          RUBY
        end
      end

      context 'with a unique index' do
        let(:schema) { <<~RUBY }
          ActiveRecord::Schema.define(version: 2020_02_02_075409) do
            create_table "users", force: :cascade do |t|
              t.string "account", null: false
            end
            add_index "users", ["account"], name: "index_users_on_account", unique: true
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
    end

    context 'when the table does not exist' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "users", force: :cascade do |t|
            t.string "account", null: false, unique: true
          end
        end
      RUBY

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class Article
            validates :account, uniqueness: true
          end
        RUBY
      end
    end

    context 'when module' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "users", force: :cascade do |t|
            t.string "account", null: false, unique: true
          end
        end
      RUBY

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          module User
            extend ActiveSupport::Concern
            included do
              validates :account, uniqueness: true
            end
          end
        RUBY
      end
    end
  end
end
