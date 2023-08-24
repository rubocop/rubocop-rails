# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DangerousColumnNames, :config do
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
      expect_offense(<<~RUBY)
        create_table :users do |t|
          t.string :save
                   ^^^^^ Avoid dangerous column names.
        end
      RUBY
    end
  end

  context 'with dangerous column name on `t.rename`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        create_table :users do |t|
          t.rename :name, :save
                          ^^^^^ Avoid dangerous column names.
        end
      RUBY
    end
  end
end
