# frozen_string_literal: true
require 'spec_helper'

RSpec.describe RuboCop::Cop::Rails::BelongsToNotOptional, :config do
  context 'without db/schema.rb' do
    it 'does nothing' do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          belongs_to "company", optional: true
        end
      RUBY
    end
  end

  context 'with db/schema.rb' do
    include_context 'with SchemaLoader'

    context 'when the table has required belongs_to' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "company", force: :cascade do |t|
            t.string "name"
          end

          create_table "users", force: :cascade do |t|
            t.string "name"
            t.belongs_to "company_id", null: false
          end
        end
      RUBY

      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class User
            belongs_to "company", optional: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Relationship is required. Either remove 'optional: true' or add a NOT NULL constraint to column.
          end
        RUBY
      end

      it 'correctly autocorrects' do
        new_source = autocorrect_source(<<~RUBY)
          class User
            belongs_to "company", optional: true
          end
        RUBY

        expect(new_source).to eq(<<~RUBY)
          class User
            belongs_to "company"
          end
        RUBY
      end

      context 'when belongs_has other arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
          class User
            belongs_to "company", inverse_of: 'authors', optional: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Relationship is required. Either remove 'optional: true' or add a NOT NULL constraint to column.
          end
          RUBY
        end

        it 'correctly autocorrects' do
          new_source = autocorrect_source(<<~RUBY)
          class User
            belongs_to "company", inverse_of: 'authors', optional: true
          end
          RUBY

          expect(new_source).to eq(<<~RUBY)
          class User
            belongs_to "company", inverse_of: 'authors'
          end
          RUBY
        end
      end
    end

    context 'when the table has an optional belongs_to' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "company", force: :cascade do |t|
            t.string "name"
          end

          create_table "users", force: :cascade do |t|
            t.string "name"
            t.belongs_to "company_id", null: true
          end
        end
      RUBY

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class User
            belongs_to "company", optional: true
          end
        RUBY
      end
    end

    context 'with namespaced model' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "company", force: :cascade do |t|
            t.string "name"
          end

          create_table "admin_users", force: :cascade do |t|
            t.string "name"
            t.belongs_to "company_id", null: false
          end
        end
      RUBY

      it 'registers an offense for nested class' do
        expect_offense(<<~RUBY)
          module Admin
            class User
              belongs_to "company", optional: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Relationship is required. Either remove 'optional: true' or add a NOT NULL constraint to column.
            end
          end
        RUBY
      end

      it 'registers an offense for compact styled class' do
        expect_offense(<<~RUBY)
          class Admin::User
            belongs_to "company", optional: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Relationship is required. Either remove 'optional: true' or add a NOT NULL constraint to column.
          end
        RUBY
      end
    end

    context 'when the table does not exist' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "users", force: :cascade do |t|
            t.string "name"
          end
        end
      RUBY

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class Article
            belongs_to "company", optional: true
          end
        RUBY
      end
    end

    context 'when module' do
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "users", force: :cascade do |t|
            belongs_to "company", optional: true
          end
        end
      RUBY

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          module User
            extend ActiveSupport::Concern
            included do
              belongs_to "company", optional: true
            end
          end
        RUBY
      end
    end
  end
end