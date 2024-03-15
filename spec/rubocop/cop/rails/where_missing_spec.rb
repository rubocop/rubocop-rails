# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::WhereMissing, :config do
  context 'Rails 6.1', :rails61 do
    it 'registers an offense when using `left_joins(:foo).where(foos: {id: nil})`' do
      expect_offense(<<~RUBY)
        Foo.left_joins(:foo).where(foos: { id: nil }).where(bar: "bar")
            ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.where.missing(:foo).where(bar: "bar")
      RUBY
    end

    it 'registers an offense when using `left_joins(:foo).where(foo: {id: nil})`' do
      expect_offense(<<~RUBY)
        Foo.left_joins(:foo).where(foo: { id: nil }).where(bar: "bar")
            ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foo: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.where.missing(:foo).where(bar: "bar")
      RUBY
    end

    it 'registers an offense when using `left_joins(:foo).where(foo: {id: nil})` without receiver' do
      expect_offense(<<~RUBY)
        left_joins(:foo).where(foo: { id: nil }).where(bar: "bar")
        ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foo: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        where.missing(:foo).where(bar: "bar")
      RUBY
    end

    it 'registers an offense when using `left_outer_joins(:foo).where(foos: {id: nil})`' do
      expect_offense(<<~RUBY)
        Foo.left_outer_joins(:foo).where(foos: { id: nil }).where(bar: "bar")
            ^^^^^^^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_outer_joins(:foo).where(foos: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.where.missing(:foo).where(bar: "bar")
      RUBY
    end

    it 'registers an offense when using `where(foos: {id: nil}).left_joins(:foo)`' do
      expect_offense(<<~RUBY)
        Foo.where(foos: { id: nil }).left_joins(:foo).where(bar: "bar")
                                     ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.where.missing(:foo).where(bar: "bar")
      RUBY
    end

    it 'registers an offense when using `where(foos: {id: nil}).left_joins(:foo)` without receiver' do
      expect_offense(<<~RUBY)
        where(foos: { id: nil }).left_joins(:foo).where(bar: "bar")
                                 ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        where.missing(:foo).where(bar: "bar")
      RUBY
    end

    it 'registers an offense when using `where(foos: {id: nil}, bar: "bar").left_joins(:foo)`' do
      expect_offense(<<~RUBY)
        Foo.where(foos: { id: nil }, bar: "bar").left_joins(:foo)
                                                 ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.where(bar: "bar").where.missing(:foo)
      RUBY
    end

    it 'registers an offense when using `where(foos: {id: nil}, bar: "bar").left_joins(:foo)` without receiver' do
      expect_offense(<<~RUBY)
        where(foos: { id: nil }, bar: "bar").left_joins(:foo)
                                             ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        where(bar: "bar").where.missing(:foo)
      RUBY
    end

    it "registers an offense when using `left_joins(:foo).where(foos: {id: nil}, bar: 'bar')`" do
      expect_offense(<<~RUBY)
        Foo.left_joins(:foo).where(foos: { id: nil }, bar: "bar")
            ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.where.missing(:foo).where(bar: "bar")
      RUBY
    end

    it "registers an offense when using `left_joins(:foo).where(bar: 'bar', foos: {id: nil})`" do
      expect_offense(<<~RUBY)
        Foo.left_joins(:foo).where(bar: "bar", foos: { id: nil })
            ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.where.missing(:foo).where(bar: "bar")
      RUBY
    end

    it 'registers an offense when using `where(foos: {id: nil}).joins(:bar).left_joins(:foo)`' do
      expect_offense(<<~RUBY)
        Foo.left_joins(:foo).joins(:bar).where(foos: { id: nil })
            ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.where.missing(:foo).joins(:bar)
      RUBY
    end

    it 'registers an offense when using `left_joins(:foo).where(foos: {id: nil})` with multi-line leading ' \
       'dot method calls' do
      expect_offense(<<~RUBY)
        Foo
          .left_joins(:foo)
           ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
          .where(foos: { id: nil })
          .where(bar: "bar")
      RUBY

      expect_correction(<<~RUBY)
        Foo
          .where.missing(:foo)
          .where(bar: "bar")
      RUBY
    end

    it "registers an offense when using `left_joins(:foo).where(foos: {id: nil}, bar: 'bar')` " \
       'with multi-line leading dot method calls' do
      expect_offense(<<~RUBY)
        Foo
          .left_joins(:foo)
           ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
          .where(foos: { id: nil }, bar: "bar")
      RUBY

      expect_correction(<<~RUBY)
        Foo
          .where.missing(:foo)
          .where(bar: "bar")
      RUBY
    end

    it "registers an offense when using `left_joins(:foo).where(foos: {id: nil}, bar: 'bar')` " \
       'with multi-line leading dot method calls and multiline where' do
      expect_offense(<<~RUBY)
        Foo
          .left_joins(:foo)
           ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
          .where(
            foos: { id: nil },
            bar: "bar"
          )
      RUBY

      expect_correction(<<~RUBY)
        Foo
          .where.missing(:foo)
          .where(
            bar: "bar"
          )
      RUBY
    end

    it 'registers an offense when using `left_joins(:foo).where(foos: {id: nil})` with multi-line trailing ' \
       'dot method calls' do
      expect_offense(<<~RUBY)
        Foo.
          left_joins(:foo).
          ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
          where(foos: { id: nil }).
          where(bar: "bar")
      RUBY

      expect_correction(<<~RUBY)
        Foo.
          where.missing(:foo).
          where(bar: "bar")
      RUBY
    end

    it 'registers an offense when using `left_joins(:foo).where(foos: {id: nil})` and there is a line break after ' \
       '`left_joins.where`' do
      expect_offense(<<~RUBY)
        Foo.left_joins(:foo).where(foos: { id: nil })
            ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
          .where(bar: "bar")
      RUBY

      expect_correction(<<~RUBY)
        Foo.where.missing(:foo)
          .where(bar: "bar")
      RUBY
    end

    it 'registers an offense when using `left_joins(:foo).where(bar: "bar").where(foos: {id: nil})` and ' \
       'there is a line break after `where(bar: "bar")`' do
      expect_offense(<<~RUBY)
        Foo
          .left_joins(:foo).where(bar: "bar")
           ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
          .where(foos: { id: nil })
      RUBY

      expect_correction(<<~RUBY)
        Foo
          .where.missing(:foo).where(bar: "bar")
      RUBY
    end

    it 'registers an offense when using `left_joins(:foo).where(foos: {id: nil})` and there is a line break after ' \
       '`left_joins.where` and receiver' do
      expect_offense(<<~RUBY)
        Foo
          .left_joins(:foo).where(foos: { id: nil })
           ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
          .where(bar: "bar")
      RUBY

      expect_correction(<<~RUBY)
        Foo
          .where.missing(:foo)
          .where(bar: "bar")
      RUBY
    end

    it "registers an offense when using `left_joins(:foo).where(foos: {id: nil}, bar: 'bar')` " \
       'with other `left_joins(:foo)`' do
      expect_offense(<<~RUBY)
        def test
          Foo.left_joins(:foo).any?

          do_something

          Foo.left_joins(:foo).where(foos: {id: nil})
              ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def test
          Foo.left_joins(:foo).any?

          do_something

          Foo.where.missing(:foo)
        end
      RUBY
    end

    it 'does not register an offense when `left_joins(:foo)` and `where(foos: {id: nil})` separated by `or`' do
      expect_no_offenses(<<~RUBY)
        Foo.left_joins(:foo).or(Foo.where(foos: {id: nil}))
      RUBY
    end

    it 'does not register an offense when `left_joins(:foo)` and `where(foos: {id: nil})` separated by `and`' do
      expect_no_offenses(<<~RUBY)
        Foo.where(foos: {id: nil}).and(Foo.left_joins(:foo))
      RUBY
    end

    it 'registers an offense when using `left_joins(:foo).where(foo: {id: nil})` outside `or` conditional expression' do
      expect_offense(<<~RUBY)
        Foo.left_joins(:foo).where(foos: {id: nil}).or(Foo.where(bar: "bar").left_joins(:foo))
            ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.where.missing(:foo).or(Foo.where(bar: "bar").left_joins(:foo))
      RUBY
    end

    it 'registers an offense when using `left_joins(:foo).where(foo: {id: nil})` within `and` conditional expression' do
      expect_offense(<<~RUBY)
        Foo.left_joins(:foo).where(bar: "bar").and(Foo.where(foos: {id: nil}).left_joins(:foo))
                                                                              ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
      RUBY

      expect_correction(<<~RUBY)
        Foo.left_joins(:foo).where(bar: "bar").and(Foo.where.missing(:foo))
      RUBY
    end

    it "registers an offense when using `left_joins(:foo).where(foos: {id: nil}, bar: 'bar')` " \
       "with other `left_joins(:foo).where(foos: {id: nil}, bar: 'bar')`" do
      expect_offense(<<~RUBY)
        def test
          Foo.left_joins(:foo).where(foos: {id: nil})
              ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.

          do_something

          Foo.left_joins(:foo).where(foos: {id: nil})
              ^^^^^^^^^^^^^^^^ Use `where.missing(:foo)` instead of `left_joins(:foo).where(foos: { id: nil })`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def test
          Foo.where.missing(:foo)

          do_something

          Foo.where.missing(:foo)
        end
      RUBY
    end

    it 'does not register an offense when `left_joins` and `where` argument is not same relationship' do
      expect_no_offenses(<<~RUBY)
        Foo.left_joins(:foo).where(bazs: { id: nil })
        Foo.left_joins(:foobar).where(foo: { id: nil })
        Foo.left_joins(:foo).where(foobar: { id: nil })
      RUBY
    end

    it 'does not register an offense when not narrowing by id' do
      expect_no_offenses(<<~RUBY)
        Foo.left_joins(:foo).where(foos: { name: nil })
      RUBY
    end

    it 'does not register an offense when not finding missing relationship records' do
      expect_no_offenses(<<~RUBY)
        Foo.left_joins(:foo).where(foos: { id: 1 })
      RUBY
    end

    it 'does not register an offense when multiple association-specified `left_joins`' do
      expect_no_offenses(<<~RUBY)
        Foo.left_joins(foo: :bar).where(bars: { id: nil })
        Foo.left_joins(bar: :foo).where(bars: { id: nil })
      RUBY
    end

    it 'does not register an offense when using `left_joins` without arguments' do
      expect_no_offenses(<<~RUBY)
        Foo.left_joins(left_joins).where(bars: { id: nil })
      RUBY
    end
  end

  context 'Rails 6.0', :rails60 do
    it 'does not register an offense when using `left_joins(:foo).where(foos: {id: nil})`' do
      expect_no_offenses(<<~RUBY)
        Foo.left_joins(:foo).where(foos: { id: nil }).where(bar: "bar")
      RUBY
    end

    it 'does not register an offense when using `left_outer_joins(:foo).where(foos: {id: nil})`' do
      expect_no_offenses(<<~RUBY)
        Foo.left_outer_joins(:foo).where(foos: { id: nil }).where(bar: "bar")
      RUBY
    end
  end
end
