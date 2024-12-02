# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DangerousColumnNames, :config do
  let(:config) do
    RuboCop::Config.new('AllCops' => { 'MigratedSchemaVersion' => '20240101010101' })
  end

  context 'with non-dangerous column name' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        add_column :users, :name, :string
      RUBY
    end
  end

  context 'with dangerous column name on `add_column`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        add_column :users, :save, :string
                           ^^^^^ Avoid dangerous column names.
      RUBY
    end
  end

  context 'with dangerous column name on `add_column` when migration file was migrated' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, '20190101010101_add_save_to_users.rb')
        add_column :users, :save, :string
      RUBY
    end
  end

  context 'with dangerous column name on `rename_column`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        rename_column :users, :name, :save
                                     ^^^^^ Avoid dangerous column names.
      RUBY
    end
  end

  context 'with dangerous column name on `t.string`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, '20250101010101_create_users.rb')
        create_table :users do |t|
          t.string :save
                   ^^^^^ Avoid dangerous column names.
        end
      RUBY
    end
  end

  context 'with dangerous column name on `t.rename`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, '20250101010101_create_users.rb')
        create_table :users do |t|
          t.rename :name, :save
                          ^^^^^ Avoid dangerous column names.
        end
      RUBY
    end
  end
end
