# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::AssertNotPredicate, :config do
  it 'registers an offense when using assert_not with predicate method' do
    expect_offense(<<~RUBY)
      assert_not(obj.one?)
      ^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_not_predicate(obj, :one?)`.
    RUBY

    expect_correction(<<~RUBY)
      assert_not_predicate(obj, :one?)
    RUBY
  end

  it 'registers an offense when using assert_not with predicate method and message' do
    expect_offense(<<~RUBY)
      assert_not(obj.one?, 'message')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_not_predicate(obj, :one?, 'message')`.
    RUBY

    expect_correction(<<~RUBY)
      assert_not_predicate(obj, :one?, 'message')
    RUBY
  end

  it 'registers an offense when using assert_not with predicate method and heredoc message' do
    expect_offense(<<~RUBY)
      assert_not(obj.one?, <<~MESSAGE)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_not_predicate(obj, :one?, <<~MESSAGE)`.
        message
      MESSAGE
    RUBY

    expect_correction(<<~RUBY)
      assert_not_predicate(obj, :one?, <<~MESSAGE)
        message
      MESSAGE
    RUBY
  end

  it 'registers and offense when using assert_not with receiver omitted predicate method' do
    expect_offense(<<~RUBY)
      assert_not(one?)
      ^^^^^^^^^^^^^^^^ Prefer using `assert_not_predicate(self, :one?)`.
    RUBY

    expect_correction(<<~RUBY)
      assert_not_predicate(self, :one?)
    RUBY
  end

  it 'registers no offense when using assert_not_predicate method' do
    expect_no_offenses(<<~RUBY)
      assert_not_predicate(obj, :one?)
    RUBY
  end

  it 'registers no offense when using assert_not with non predicate method' do
    expect_no_offenses(<<~RUBY)
      assert_not(obj.do_something)
    RUBY
  end

  it 'registers no offense when using assert_not with local variable' do
    expect_no_offenses(<<~RUBY)
      obj = create_obj
      assert_not(obj)
    RUBY
  end

  it 'registers no offense when using assert_not_predicate with predicate method and arguments' do
    expect_no_offenses(<<~RUBY)
      assert_not(obj.foo?(arg))
    RUBY
  end

  it 'registers no offense when using assert_not with predicate method and numbered arguments' do
    expect_no_offenses(<<~RUBY)
      assert_not([1, 2, 3].any? { some_filter_function _1 })
    RUBY
  end

  it 'raises no error when using assert_not with block' do
    expect_no_offenses(<<~RUBY)
      assert_not { false }
    RUBY
  end
end
