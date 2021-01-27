# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ArelStar, :config do
  it 'registers an offense and corrects when an asterisk is used on an Arel::Table column reference' do
    expect_offense(<<~RUBY)
      class MyModel < ApplicationRecord
        scope :my_scope, -> { select(arel_table["*"]) }
                                                ^^^ Use `Arel.star` instead of `"*"` for expanded column lists.
      end
    RUBY

    expect_correction(<<~RUBY)
      class MyModel < ApplicationRecord
        scope :my_scope, -> { select(arel_table[Arel.star]) }
      end
    RUBY
  end

  it 'registers an offense on the `arel_table` object in a void' do
    expect_offense(<<~RUBY)
      arel_table["*"]
                 ^^^ Use `Arel.star` instead of `"*"` for expanded column lists.
    RUBY

    expect_correction(<<~RUBY)
      arel_table[Arel.star]
    RUBY
  end

  it 'registers an offense on the `arel_table` object on a model' do
    expect_offense(<<~RUBY)
      MyModel.arel_table["*"]
                         ^^^ Use `Arel.star` instead of `"*"` for expanded column lists.
    RUBY

    expect_correction(<<~RUBY)
      MyModel.arel_table[Arel.star]
    RUBY
  end

  it 'registers an offense for ArelExtensions asterisks' do
    expect_offense(<<~RUBY)
      MyModel["*"]
              ^^^ Use `Arel.star` instead of `"*"` for expanded column lists.
    RUBY

    expect_correction(<<~RUBY)
      MyModel[Arel.star]
    RUBY
  end

  it 'does not register an offense on an object not named `arel_table`' do
    expect_no_offenses(<<~RUBY)
      hsh = { '*' => 'foo' }
      hsh['*']
    RUBY
  end
end
