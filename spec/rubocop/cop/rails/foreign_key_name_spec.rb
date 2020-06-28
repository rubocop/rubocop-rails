# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ForeignKeyName, :config do
  it 'registers an offense when using `add_foreign_key` without a name' do
    expect_offense(<<~RUBY)
      add_foreign_key :articles, :authors
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Name your foreign keys explicitly instead of relying on Rails auto-generated FK names.
    RUBY

    expect_correction(<<~RUBY)
      add_foreign_key :articles, :authors, name: :articles_author_id_fk
    RUBY
  end

  it 'does not register an offense when using `add_foreign_key` with a name' do
    expect_no_offenses(<<~RUBY)
      add_foreign_key :articles, :authors, name: :articles_authors_fk
    RUBY
  end

  it 'registers an offense when using `foreign_key` without a name' do
    expect_offense(<<~RUBY)
      change_table(:articles) do |t|
        t.string :title
        t.foreign_key :authors
        ^^^^^^^^^^^^^^^^^^^^^^ Name your foreign keys explicitly instead of relying on Rails auto-generated FK names.
        t.timestamps
      end
    RUBY

    expect_correction(<<~RUBY)
      change_table(:articles) do |t|
        t.string :title
        t.foreign_key :authors, name: :articles_author_id_fk
        t.timestamps
      end
    RUBY
  end

  it 'does not register an offense when using `foreign_key` with a name' do
    expect_no_offenses(<<~RUBY)
      t.foreign_key :authors, name: :articles_authors_fk
    RUBY
  end

  context 'when custom column name is used' do
    it 'registers an offense when using `add_foreign_key` without a name' do
      expect_offense(<<~RUBY)
        add_foreign_key :articles, :authors, column: :author_id
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Name your foreign keys explicitly instead of relying on Rails auto-generated FK names.
      RUBY

      expect_correction(<<~RUBY)
        add_foreign_key :articles, :authors, column: :author_id, name: :articles_author_id_fk
      RUBY
    end

    %i[create_table change_table].each do |table_method|
      it "registers an offense when using `foreign_key` in #{table_method} without a name" do
        expect_offense(<<~RUBY)
          #{table_method}(:articles) do |t|
            t.foreign_key :authors, column: :creator_id
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Name your foreign keys explicitly instead of relying on Rails auto-generated FK names.
          end
        RUBY

        expect_correction(<<~RUBY)
          #{table_method}(:articles) do |t|
            t.foreign_key :authors, column: :creator_id, name: :articles_creator_id_fk
          end
        RUBY
      end
    end

    it 'does not register an offense for custom table method' do
      expect_no_offenses(<<~RUBY)
        create_table_with_constraints(:articles) do |t|
          t.foreign_key :authors
        end
      RUBY
    end
  end

  context 'StartAfterMigrationVersion is used' do
    let(:cop_config) do
      { 'StartAfterMigrationVersion' => '2021_10_07_00_00_01' }
    end

    it 'registers an offense for newer migrations' do
      expect_offense(<<~RUBY, 'db/migrate/20211007000002_create_articles.rb')
        add_foreign_key :articles, :authors
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Name your foreign keys explicitly instead of relying on Rails auto-generated FK names.
      RUBY
    end

    it 'does not register an offense for older migrations' do
      expect_no_offenses(<<~RUBY, 'db/migrate/20211007000001_create_articles.rb')
        add_foreign_key :articles, :authors
      RUBY
    end
  end
end
