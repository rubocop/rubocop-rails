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

  context 'when the class name contains a dot in its file name' do
    let(:filename) { 'db/migrate/20220101050505_add_blobs.active_storage.rb' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, filename)
        class AddBlobs < ActiveRecord::Migration[7.0]
        end
      RUBY
    end
  end
end
