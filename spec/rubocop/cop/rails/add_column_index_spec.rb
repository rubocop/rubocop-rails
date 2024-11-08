# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::AddColumnIndex, :config do
  let(:config) do
    RuboCop::Config.new('AllCops' => { 'MigratedSchemaVersion' => '20240101010101' })
  end

  it 'registers an offense and corrects when an `add_column` call has `index: true`' do
    expect_offense(<<~RUBY, '20250101010101_add_column_to_table.rb')
      add_column :table, :column, :integer, default: 0, index: true
                                                        ^^^^^^^^^^^ `add_column` does not accept an `index` key, use `add_index` instead.
    RUBY

    expect_correction(<<~RUBY)
      add_column :table, :column, :integer, default: 0
      add_index :table, :column
    RUBY
  end

  it 'registers an offense and corrects when an `add_column` call has `index:` with a hash' do
    expect_offense(<<~RUBY, '20250101010101_add_column_to_table.rb')
      add_column :table, :column, :integer, default: 0, index: { unique: true, name: 'my_unique_index' }
                                                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `add_column` does not accept an `index` key, use `add_index` instead.
    RUBY

    expect_correction(<<~RUBY)
      add_column :table, :column, :integer, default: 0
      add_index :table, :column, unique: true, name: 'my_unique_index'
    RUBY
  end

  it 'registers an offense and corrects with there is another hash key after `index`' do
    expect_offense(<<~RUBY, '20250101010101_add_column_to_table.rb')
      add_column :table, :column, :integer, index: true, default: 0
                                            ^^^^^^^^^^^ `add_column` does not accept an `index` key, use `add_index` instead.
    RUBY

    expect_correction(<<~RUBY)
      add_column :table, :column, :integer, default: 0
      add_index :table, :column
    RUBY
  end

  it 'registers an offense and corrects with string keys' do
    expect_offense(<<~RUBY, '20250101010101_add_column_to_table.rb')
      add_column :table, :column, :integer, 'index' => true, default: 0
                                            ^^^^^^^^^^^^^^^ `add_column` does not accept an `index` key, use `add_index` instead.
    RUBY

    expect_correction(<<~RUBY)
      add_column :table, :column, :integer, default: 0
      add_index :table, :column
    RUBY
  end

  it 'registers an offense and corrects when on multiple lines' do
    expect_offense(<<~RUBY, '20250101010101_add_column_to_table.rb')
      add_column :table, :column, :integer,
                 index: true,
                 ^^^^^^^^^^^ `add_column` does not accept an `index` key, use `add_index` instead.
                 default: 0
    RUBY

    expect_correction(<<~RUBY)
      add_column :table, :column, :integer,
                 default: 0
      add_index :table, :column
    RUBY
  end

  it 'can correct multiple `add_column` calls' do
    expect_offense(<<~RUBY, '20250101010101_add_column_to_table.rb')
      add_column :table, :column, :integer, default: 0, index: true
                                                        ^^^^^^^^^^^ `add_column` does not accept an `index` key, use `add_index` instead.
      add_column :table, :column2, :integer, default: 0, index: true
                                                         ^^^^^^^^^^^ `add_column` does not accept an `index` key, use `add_index` instead.
    RUBY

    expect_correction(<<~RUBY)
      add_column :table, :column, :integer, default: 0
      add_index :table, :column
      add_column :table, :column2, :integer, default: 0
      add_index :table, :column2
    RUBY
  end

  it 'does not register an offense without an `index` key to `add_column`' do
    expect_no_offenses(<<~RUBY)
      add_column :table, :column, :integer, default: 0
    RUBY
  end

  context '`MigratedSchemaVersion` is an integer' do
    let(:config) do
      RuboCop::Config.new('AllCops' => { 'MigratedSchemaVersion' => 20240101010101 }) # rubocop:disable Style/NumericLiterals
    end

    it 'registers an offense and corrects when an `add_column` call has `index: true`' do
      expect_offense(<<~RUBY, '20250101010101_add_column_to_table.rb')
        add_column :table, :column, :integer, default: 0, index: true
                                                          ^^^^^^^^^^^ `add_column` does not accept an `index` key, use `add_index` instead.
      RUBY

      expect_correction(<<~RUBY)
        add_column :table, :column, :integer, default: 0
        add_index :table, :column
      RUBY
    end
  end
end
