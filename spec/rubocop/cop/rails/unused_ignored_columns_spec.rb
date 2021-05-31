# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::UnusedIgnoredColumns, :config do
  context 'without db/schema.rb' do
    it 'does nothing' do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          self.ignored_columns = [:real_name]
        end
      RUBY
    end
  end

  context 'with db/schema.rb' do
    include_context 'with SchemaLoader'

    let(:schema) { <<~RUBY }
      ActiveRecord::Schema.define(version: 2020_02_02_075409) do
        create_table "users", force: :cascade do |t|
          t.string "account", null: false
        end
      end
    RUBY

    context 'with an unused ignored column as a Symbol' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class User < ApplicationRecord
            self.ignored_columns = [:real_name]
                                    ^^^^^^^^^^ Remove `real_name` from `ignored_columns` because the column does not exist.
          end
        RUBY
      end
    end

    context 'with an unused ignored column as a String' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class User < ApplicationRecord
            self.ignored_columns = ['real_name']
                                    ^^^^^^^^^^^ Remove `real_name` from `ignored_columns` because the column does not exist.
          end
        RUBY
      end
    end

    context 'when ignored_columns= receives existent column as a Symbol' do
      it 'does nothing' do
        expect_no_offenses(<<~RUBY)
          class User < ApplicationRecord
            self.ignored_columns = [:account]
          end
        RUBY
      end
    end

    context 'when ignored_columns= receives existent column as a String' do
      it 'does nothing' do
        expect_no_offenses(<<~RUBY)
          class User < ApplicationRecord
            self.ignored_columns = ['account']
          end
        RUBY
      end
    end

    context 'with existent and nonexistent columns as Symbol' do
      it 'registers an offense to the nonexistent column' do
        expect_offense(<<~RUBY)
          class User < ApplicationRecord
            self.ignored_columns = [:real_name, :account]
                                    ^^^^^^^^^^ Remove `real_name` from `ignored_columns` because the column does not exist.
          end
        RUBY
      end
    end

    context 'with existent and nonexistent columns as String' do
      it 'registers an offense to the nonexistent column' do
        expect_offense(<<~RUBY)
          class User < ApplicationRecord
            self.ignored_columns = ['real_name', 'account']
                                    ^^^^^^^^^^^ Remove `real_name` from `ignored_columns` because the column does not exist.
          end
        RUBY
      end
    end

    context 'when ignored_columns= receives not a literal' do
      it 'does nothing' do
        expect_no_offenses(<<~RUBY)
          class User < ApplicationRecord
            self.ignored_columns = array
          end
        RUBY
      end
    end
  end
end
