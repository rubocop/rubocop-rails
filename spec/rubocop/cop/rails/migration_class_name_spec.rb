# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::MigrationClassName, :config do
  let(:config) do
    RuboCop::Config.new('AllCops' => { 'MigratedSchemaVersion' => '20240101010101' })
  end
  let(:filename) { 'db/migrate/20250101010101_create_users.rb' }

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
          class Article < ActiveRecord::Base
          end

          class CreateUsers < ActiveRecord::Migration[7.0]
          end
        RUBY
      end
    end

    context 'when defining an inner class' do
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

  context 'when the class name does not match its file name and class name is prefixed with `::`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, filename)
        class ::SellBooks < ActiveRecord::Migration[7.0]
                ^^^^^^^^^ Replace with `CreateUsers` that matches the file name.
        end
      RUBY

      expect_correction(<<~RUBY)
        class ::CreateUsers < ActiveRecord::Migration[7.0]
        end
      RUBY
    end
  end

  context 'when the class name contains a dot in its file name' do
    let(:filename) { 'db/migrate/20220101050505_add_blobs.active_storage.rb' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, filename)
        class AddBlobs < ActiveRecord::Migration[7.0]
        end
      RUBY
    end
  end

  #
  # When `OAuth` is applied instead of `Oauth` for `oauth`.
  #
  # # config/initializers/inflections.rb
  # ActiveSupport::Inflector.inflections(:en) do |inflect|
  #   inflect.acronym 'OAuth'
  # end
  #
  context 'when `ActiveSupport::Inflector` is applied to the class name and the case is different' do
    let(:filename) { 'db/migrate/20250101010101_remove_unused_oauth_scope_grants.rb' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, filename)
        class RemoveUnusedOAuthScopeGrants < ActiveRecord::Migration[7.0]
        end
      RUBY
    end
  end
end
