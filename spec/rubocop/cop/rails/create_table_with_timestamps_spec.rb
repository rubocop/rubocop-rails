# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::CreateTableWithTimestamps, :config do
  it 'registers an offense when calling `#create_table` without block' do
    expect_offense <<~RUBY
      create_table :users
      ^^^^^^^^^^^^^^^^^^^ Add timestamps when creating a new table.
    RUBY
  end

  it 'registers an offense when not including timestamps in empty block' do
    expect_offense <<~RUBY
      create_table :users do |t|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add timestamps when creating a new table.
      end
    RUBY
  end

  it 'registers an offense when not including timestamps in one line block' do
    expect_offense <<~RUBY
      create_table :users do |t|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add timestamps when creating a new table.
        t.string :name
      end
    RUBY
  end

  it 'registers an offense when not including timestamps in multiline block' do
    expect_offense <<~RUBY
      create_table :users do |t|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add timestamps when creating a new table.
        t.string :name
        t.string :email
      end
    RUBY
  end

  it 'registers an offense when not including timestamps with `to_proc` syntax' do
    expect_offense <<~RUBY
      create_table :users, &:extension_columns
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add timestamps when creating a new table.
    RUBY
  end

  it 'does not register an offense when including timestamps in block' do
    expect_no_offenses <<~RUBY
      create_table :users do |t|
        t.string :name
        t.string :email

        t.timestamps
      end
    RUBY
  end

  it 'does not register an offense when including timestamps in numblock' do
    expect_no_offenses <<~RUBY
      create_table :users do
        _1.string :name
        _1.string :email

        _1.timestamps
      end
    RUBY
  end

  it 'does not register an offense when including timestamps with `to_proc` syntax' do
    expect_no_offenses <<~RUBY
      create_table :users, &:timestamps
    RUBY
  end

  it 'does not register an offense when including timestamps with options and `to_proc` syntax' do
    expect_no_offenses <<~RUBY
      create_table :users, id: :string, limit: 42, &:timestamps
    RUBY
  end

  it 'does not register an offense when including :created_at in block' do
    expect_no_offenses <<~RUBY
      create_table :users do |t|
        t.string :name
        t.string :email

        t.datetime :created_at, default: -> { 'CURRENT_TIMESTAMP' }
      end
    RUBY
  end

  it "does not register an offense when including 'created_at' in block" do
    expect_no_offenses <<~RUBY
      create_table :users do |t|
        t.string :name
        t.string :email

        t.datetime 'created_at', default: -> { 'CURRENT_TIMESTAMP' }
      end
    RUBY
  end

  it 'does not register an offense when including :updated_at in block' do
    expect_no_offenses <<~RUBY
      create_table :users do |t|
        t.string :name
        t.string :email

        t.datetime :updated_at, default: -> { 'CURRENT_TIMESTAMP' }
      end
    RUBY
  end

  it "does not register an offense when including 'updated_at' in block" do
    expect_no_offenses <<~RUBY
      create_table :users do |t|
        t.string :name
        t.string :email

        t.datetime 'updated_at', default: -> { 'CURRENT_TIMESTAMP' }
      end
    RUBY
  end

  it 'does not register an offense when using `id: false` option and not including `timestamps` in block' do
    expect_no_offenses(<<~RUBY)
      create_table :users, :articles, id: false do |t|
        t.integer :user_id
        t.integer :article_id
      end
    RUBY
  end
end
