# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TableNameAssignment, :config do
  context 'when table_name is defined' do
    context 'when string' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class AModule::SomeModel < ApplicationRecord
            self.table_name = 'some_other_table_name'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `self.table_name =`.
          end
        RUBY
      end
    end

    context 'when string = foo' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class AModule::SomeModel < ApplicationRecord
            self.table_name = 'foo'
            ^^^^^^^^^^^^^^^^^^^^^^^ Do not use `self.table_name =`.
          end
        RUBY
      end
    end

    context 'when symbol' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class AModule::SomeModel < ApplicationRecord
            self.table_name = :some_other_table_name
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `self.table_name =`.
          end
        RUBY
      end
    end

    context 'when symbol = :foo' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class AModule::SomeModel < ApplicationRecord
            self.table_name = :foo
            ^^^^^^^^^^^^^^^^^^^^^^ Do not use `self.table_name =`.
          end
        RUBY
      end
    end
  end

  context 'when table_name is not defined' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class AModule::SomeModel < ApplicationRecord
          has_many :other_thing
          has_one :parent_thing
        end
      RUBY
    end
  end

  # Case for STI base classes
  context 'when class is named `Base`' do
    context 'when class is declared with module' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class A::B::Base < ApplicationRecord
            has_many :other_thing
            has_one :parent_thing

            self.table_name = 'special_table_name'
          end
        RUBY
      end
    end

    context 'when class is declared within module' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          module A
            module B
              class Base < ApplicationRecord
                has_many :other_thing
                has_one :parent_thing

                self.table_name = 'special_table_name'
              end
            end
          end
        RUBY
      end
    end
  end
end
