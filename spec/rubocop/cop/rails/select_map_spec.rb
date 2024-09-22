# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::SelectMap, :config do
  it 'registers an offense when using `select(:column_name).map(&:column_name)`' do
    expect_offense(<<~RUBY)
      Model.select(:column_name).map(&:column_name)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `pluck(:column_name)` instead of `select` with `map`.
    RUBY

    expect_correction(<<~RUBY)
      Model.pluck(:column_name)
    RUBY
  end

  it "registers an offense when using `select('column_name').map(&:column_name)`" do
    expect_offense(<<~RUBY)
      Model.select('column_name').map(&:column_name)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `pluck(:column_name)` instead of `select` with `map`.
    RUBY

    expect_correction(<<~RUBY)
      Model.pluck(:column_name)
    RUBY
  end

  it 'registers an offense when using `select(:column_name).collect(&:column_name)`' do
    expect_offense(<<~RUBY)
      Model.select(:column_name).collect(&:column_name)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `pluck(:column_name)` instead of `select` with `collect`.
    RUBY

    expect_correction(<<~RUBY)
      Model.pluck(:column_name)
    RUBY
  end

  it 'registers an offense when using `select(:column_name).where(conditions).map(&:column_name)`' do
    expect_offense(<<~RUBY)
      Model.select(:column_name).where(conditions).map(&:column_name)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `pluck(:column_name)` instead of `select` with `map`.
    RUBY

    expect_correction(<<~RUBY)
      Model.where(conditions).pluck(:column_name)
    RUBY
  end

  it 'registers an offense when using `select(:column_name).map(&:column_name)` without receiver model' do
    expect_offense(<<~RUBY)
      select(:column_name).map(&:column_name)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `pluck(:column_name)` instead of `select` with `map`.
    RUBY

    expect_correction(<<~RUBY)
      pluck(:column_name)
    RUBY
  end

  it 'handles safe navigation chain' do
    expect_offense(<<~RUBY)
      relation&.select(:column_name)&.map(&:column_name)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `pluck(:column_name)` instead of `select` with `map`.
    RUBY

    expect_correction(<<~RUBY)
      relation&.pluck(:column_name)
    RUBY
  end

  it 'does not register an offense when using `select(:mismatch_column_name).map(&:column_name)`' do
    expect_no_offenses(<<~RUBY)
      Model.select(:mismatch_column_name).map(&:column_name)
    RUBY
  end

  it 'does not register an offense when using `select(:column_name, :other_column_name).map(&:column_name)`' do
    expect_no_offenses(<<~RUBY)
      Model.select(:column_name, :other_column_name).map(&:column_name)
    RUBY
  end

  it 'does not register an offense when using `select(column_names).map(&:column_name)`' do
    expect_no_offenses(<<~RUBY)
      Model.select(column_names).map(&:column_name)
    RUBY
  end

  it 'does not register an offense when using `select(:column_name).do_something(&:column_name)`' do
    expect_no_offenses(<<~RUBY)
      Model.select(:column_name).do_something(&:column_name)
    RUBY
  end

  it 'does not register an offense when using `select { |item| item.column_name }.map(&:column_name)`' do
    expect_no_offenses(<<~RUBY)
      Model.select { |item| item.column_name }.map(&:column_name)
    RUBY
  end

  it 'does not register an offense when using `select(:column_name).map { |item| do_something(item) }`' do
    expect_no_offenses(<<~RUBY)
      Model.select(:column_name).map { |item| do_something(item) }
    RUBY
  end

  it 'does not register an offense when using `pluck(:column_name)`' do
    expect_no_offenses(<<~RUBY)
      Model.pluck(:column_name)
    RUBY
  end
end
