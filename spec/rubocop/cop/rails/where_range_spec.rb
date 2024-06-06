# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::WhereRange, :config do
  context 'Ruby <= 2.5', :ruby25 do
    it 'does not register an offense when using anonymous `>=`' do
      expect_no_offenses(<<~RUBY)
        Model.where('column >= ?', value)
      RUBY
    end

    it 'does not register an offense when using anonymous `<=`' do
      expect_no_offenses(<<~RUBY)
        Model.where('column <= ?', value)
      RUBY
    end
  end

  context 'Rails 5.1', :rails51 do
    it 'does not register an offense when using anonymous `>=`' do
      expect_no_offenses(<<~RUBY)
        Model.where('column >= ?', value)
      RUBY
    end
  end

  context 'Rails 6.0', :rails60 do
    context 'Ruby >= 2.6', :ruby26 do
      it 'registers an offense and corrects when using anonymous `>=`' do
        expect_offense(<<~RUBY)
          Model.where('column >= ?', value)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(column: value..)` instead of manually constructing SQL.
        RUBY

        expect_correction(<<~RUBY)
          Model.where(column: value..)
        RUBY
      end

      it 'registers an offense and corrects when using named `>=`' do
        expect_offense(<<~RUBY)
          Model.where('column >= :min', min: value)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(column: value..)` instead of manually constructing SQL.
        RUBY

        expect_correction(<<~RUBY)
          Model.where(column: value..)
        RUBY
      end

      it 'registers an offense and corrects when using anonymous `>=` with an explicit table' do
        expect_offense(<<~RUBY)
          Model.where('table.column >= ?', value)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(table: { column: value.. })` instead of manually constructing SQL.
        RUBY

        expect_correction(<<~RUBY)
          Model.where(table: { column: value.. })
        RUBY
      end

      it 'does not register an offense when using anonymous `>`' do
        expect_no_offenses(<<~RUBY)
          Model.where('column > ?', value)
        RUBY
      end

      it 'registers an offense and corrects when using anonymous `>= AND <`' do
        expect_offense(<<~RUBY)
          Model.where('column >= ? AND column < ?', value1, value2)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(column: value1...value2)` instead of manually constructing SQL.
        RUBY

        expect_correction(<<~RUBY)
          Model.where(column: value1...value2)
        RUBY
      end

      it 'registers an offense and corrects when using anonymous `>= AND <=`' do
        expect_offense(<<~RUBY)
          Model.where('column >= ? AND column <= ?', value1, value2)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(column: value1..value2)` instead of manually constructing SQL.
        RUBY

        expect_correction(<<~RUBY)
          Model.where(column: value1..value2)
        RUBY
      end

      it 'registers an offense and corrects when using named `>= AND <`' do
        expect_offense(<<~RUBY)
          Model.where('column >= :min AND column < :max', min: value1, max: value2)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(column: value1...value2)` instead of manually constructing SQL.
        RUBY

        expect_correction(<<~RUBY)
          Model.where(column: value1...value2)
        RUBY
      end

      it 'does not register an offense when using different columns' do
        expect_no_offenses(<<~RUBY)
          Model.where('column1 >= ? AND column2 < ?', value1, value2)
        RUBY
      end

      it 'does not register an offense when using named `>= AND <` and placeholders do not exist' do
        expect_no_offenses(<<~RUBY)
          Model.where('column >= :min AND column < :max', min: value)
        RUBY
      end

      it 'registers an offense and corrects when using `>=` with an array' do
        expect_offense(<<~RUBY)
          Model.where(['column >= ?', value])
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(column: value..)` instead of manually constructing SQL.
        RUBY

        expect_correction(<<~RUBY)
          Model.where(column: value..)
        RUBY
      end

      it 'registers an offense and corrects when using `>= AND <=` with an array' do
        expect_offense(<<~RUBY)
          Model.where(['column >= ? AND column <= ?', value1, value2])
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(column: value1..value2)` instead of manually constructing SQL.
        RUBY

        expect_correction(<<~RUBY)
          Model.where(column: value1..value2)
        RUBY
      end

      it 'registers an offense and corrects when using `where.not`' do
        expect_offense(<<~RUBY)
          Model.where.not('column >= ?', value)
                      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `not(column: value..)` instead of manually constructing SQL.
        RUBY

        expect_correction(<<~RUBY)
          Model.where.not(column: value..)
        RUBY
      end

      it 'does not register an offense when using ranges' do
        expect_no_offenses(<<~RUBY)
          Model.where(column: value..)
        RUBY
      end

      it 'does not register an offense when using `not` with ranges' do
        expect_no_offenses(<<~RUBY)
          Model.where.not(column: value..)
        RUBY
      end

      it 'does not register an offense when using `not` not preceding by `where`' do
        expect_no_offenses(<<~RUBY)
          foo.not('column >= ?', value)
        RUBY
      end

      it 'wraps complex expressions by parentheses' do
        expect_offense(<<~RUBY)
          Model.where('column >= ?', true ? 1 : 2)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(column: (true ? 1 : 2)..)` instead of manually constructing SQL.
        RUBY

        expect_correction(<<~RUBY)
          Model.where(column: (true ? 1 : 2)..)
        RUBY
      end
    end

    context 'Ruby >= 2.6', :ruby26, unsupported_on: :prism do
      it 'does not register an offense when using anonymous `<=`' do
        expect_no_offenses(<<~RUBY)
          Model.where('column <= ?', value)
        RUBY
      end

      it 'does not register an offense when using anonymous `<`' do
        expect_no_offenses(<<~RUBY)
          Model.where('column < ?', value)
        RUBY
      end
    end

    context 'Ruby >= 2.7', :ruby27 do
      it 'registers an offense and corrects when using anonymous `<=`' do
        expect_offense(<<~RUBY)
          Model.where('column <= ?', value)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(column: ..value)` instead of manually constructing SQL.
        RUBY

        expect_correction(<<~RUBY)
          Model.where(column: ..value)
        RUBY
      end

      it 'registers an offense and corrects when using anonymous `<`' do
        expect_offense(<<~RUBY)
          Model.where('column < ?', value)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(column: ...value)` instead of manually constructing SQL.
        RUBY

        expect_correction(<<~RUBY)
          Model.where(column: ...value)
        RUBY
      end
    end
  end
end
