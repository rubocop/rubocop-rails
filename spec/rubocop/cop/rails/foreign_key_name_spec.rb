# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ForeignKeyName do
  subject(:cop) { described_class.new }

  it 'registers an offense when using `add_foreign_key` without a name' do
    expect_offense(<<~RUBY)
      add_foreign_key :articles, :authors
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Name your foreign keys explicitly instead of relying on Rails auto-generated FK names.
    RUBY
  end

  it 'does not register an offense when using `add_foreign_key` with a name' do
    expect_no_offenses(<<~RUBY)
      add_foreign_key :articles, :authors, name: :articles_authors_fk
    RUBY
  end

  it 'registers an offense when using `foreign_key` without a name' do
    expect_offense(<<~RUBY)
      t.foreign_key :authors
      ^^^^^^^^^^^^^^^^^^^^^^ Name your foreign keys explicitly instead of relying on Rails auto-generated FK names.
    RUBY
  end

  it 'does not register an offense when using `foreign_key` with a name' do
    expect_no_offenses(<<~RUBY)
      t.foreign_key :authors, name: :articles_authors_fk
    RUBY
  end
end
