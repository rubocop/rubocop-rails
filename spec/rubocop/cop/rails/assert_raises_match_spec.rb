# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::AssertRaisesMatch, :config do
  context 'when the target Rails version is >= 7.1', :rails71 do
    it 'registers an offense and folds `assert_equal` into an anchored regexp' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) { raise FooError, "boom" }
        assert_equal("boom", e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: /\\Aboom\\z/) { raise FooError, "boom" }
      RUBY
    end

    it 'escapes regexp metacharacters in the anchored regexp' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) { raise FooError }
        assert_equal("boom (42)", e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: /\\Aboom\\ \\(42\\)\\z/) { raise FooError }
      RUBY
    end

    it 'preserves a `do...end` block when folding' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) do
          raise FooError, "boom"
        end
        assert_equal("boom", e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: /\\Aboom\\z/) do
          raise FooError, "boom"
        end
      RUBY
    end

    it 'folds across an intervening statement' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) { raise FooError, "boom" }
        assert_equal(1, other)
        assert_equal("boom", e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: /\\Aboom\\z/) { raise FooError, "boom" }
        assert_equal(1, other)
      RUBY
    end

    it 'folds `assert_match` with a regexp unchanged' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) { raise FooError }
        assert_match(/boom/, e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: /boom/) { raise FooError }
      RUBY
    end

    it 'folds `assert_match` with a string as a substring match' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) { raise FooError }
        assert_match("boom", e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: "boom") { raise FooError }
      RUBY
    end

    it 'folds `assert_match` with an expression unchanged' do
      expect_offense(<<~RUBY)
        expected_message = build_expected_message
        e = assert_raises(FooError) { raise FooError }
        assert_match(expected_message, e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        expected_message = build_expected_message
        e = assert_raises(FooError, match: expected_message) { raise FooError }
      RUBY
    end

    it 'folds `assert_includes` on the message as a substring match' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) { raise FooError }
        assert_includes(e.message, "boom")
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: "boom") { raise FooError }
      RUBY
    end

    it 'folds `assert_includes` with an expression unchanged' do
      expect_offense(<<~RUBY)
        expected_message = build_expected_message
        e = assert_raises(FooError) { raise FooError }
        assert_includes(e.message, expected_message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        expected_message = build_expected_message
        e = assert_raises(FooError, match: expected_message) { raise FooError }
      RUBY
    end

    it 'inserts `match:` before a block-pass argument' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError, &block)
        assert_equal("boom", e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: /\\Aboom\\z/, &block)
      RUBY
    end

    it 'inserts `match:` after the last of multiple expected exception classes' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError, BarError) { raise FooError, "boom" }
        assert_equal("boom", e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, BarError, match: /\\Aboom\\z/) { raise FooError, "boom" }
      RUBY
    end

    it 'escapes the regexp delimiter and metacharacters from an `assert_equal` message' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) { raise FooError }
        assert_equal("a/b*c", e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: /\\Aa\\/b\\*c\\z/) { raise FooError }
      RUBY
    end

    it 'registers an offense for the `assert_raise` alias' do
      expect_offense(<<~RUBY)
        e = assert_raise(FooError) { raise FooError, "boom" }
        assert_equal("boom", e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raise(FooError, match: /\\Aboom\\z/) { raise FooError, "boom" }
      RUBY
    end

    it 'folds an `assert_equal` expected expression unchanged' do
      expect_offense(<<~RUBY)
        expected_message = build_expected_message
        e = assert_raises(FooError) { raise FooError }
        assert_equal(expected_message, e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        expected_message = build_expected_message
        e = assert_raises(FooError, match: expected_message) { raise FooError }
      RUBY
    end

    it 'folds an instance-variable expected expression unchanged' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) { raise FooError, "boom" }
        @expected_message = "boom"
        assert_equal(@expected_message, e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: @expected_message) { raise FooError, "boom" }
        @expected_message = "boom"
      RUBY
    end

    it 'folds an interpolated expected string unchanged' do
      # We leave the string as-is, because correctly handling the interpolation is too error-prone.
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) { raise FooError }
        assert_equal("Product \#{id} not found", e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: "Product \#{id} not found") { raise FooError }
      RUBY
    end

    it 'registers an offense for heredocs' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) { raise FooError }
        assert_equal(<<~MSG, e.message)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
          boom
        MSG
      RUBY
    end

    it 'does not register an offense when `assert_raises` already passes `match:`' do
      expect_no_offenses(<<~RUBY)
        e = assert_raises(FooError, match: "boom") { raise FooError, "boom" }
        assert_equal("boom", e.message)
      RUBY
    end

    it 'does not register an offense when the variable was not assigned from `assert_raises`' do
      expect_no_offenses(<<~RUBY)
        e = build_error
        assert_equal("boom", e.message)
      RUBY
    end

    it 'does not register an offense when the variable is reassigned before the message assertion' do
      expect_no_offenses(<<~RUBY)
        e = assert_raises(FooError) { raise FooError }
        e = build_error
        assert_equal("boom", e.message)
      RUBY
    end

    it 'does not register an offense when the variable is conditionally reassigned before the assertion' do
      expect_no_offenses(<<~RUBY)
        e = assert_raises(FooError) { raise FooError }
        e = build_error if use_synthetic_error?
        assert_equal("boom", e.message)
      RUBY
    end

    it 'removes only the message assertion when another statement follows on the same line' do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) { raise FooError }
        assert_equal("boom", e.message); assert_equal(1, foo)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: /\\Aboom\\z/) { raise FooError }
        assert_equal(1, foo)
      RUBY
    end

    it "removes only the message assertion when it's on the same line as the assignment" do
      expect_offense(<<~RUBY)
        e = assert_raises(FooError) { raise FooError }; assert_equal("boom", e.message)
                                                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the `match:` keyword of `assert_raises` instead of a separate assertion on the exception message.
      RUBY

      expect_correction(<<~RUBY)
        e = assert_raises(FooError, match: /\\Aboom\\z/) { raise FooError }
      RUBY
    end

    it 'does not register an offense when there are multiple message assertions on the same variable' do
      expect_no_offenses(<<~RUBY)
        e = assert_raises(FooError) { raise FooError }
        assert_equal("boom", e.message)
        assert_match(/boom/, e.message)
      RUBY
    end
  end

  context 'when the target Rails version is < 7.1', :rails70 do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        e = assert_raises(FooError) { raise FooError, "boom" }
        assert_equal("boom", e.message)
      RUBY
    end
  end
end
