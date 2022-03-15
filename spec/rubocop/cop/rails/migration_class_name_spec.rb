# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::MigrationClassName, :config do
  let(:filename) { 'db/migrate/20220101050505_create_users.rb' }

  context 'when the class name matches its file name' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, filename)
        class CreateUsers < ActiveRecord::Migration[7.0]
        end
      RUBY
    end

    context 'when defining another class' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, filename)
          class CreateUsers < ActiveRecord::Migration[7.0]
            class Article < ActiveRecord::Base
            end
          end
        RUBY
      end
    end
  end

  context 'when the class name does not match its file name' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, filename)
        class SellBooks < ActiveRecord::Migration[7.0]
              ^^^^^^^^^ Replace with `CreateUsers` that matches the file name.
        end
      RUBY

      expect_correction(<<~RUBY)
        class CreateUsers < ActiveRecord::Migration[7.0]
        end
      RUBY
    end
  end
end
