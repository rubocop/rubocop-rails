# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RefuteMethods, :config do
  let(:config) do
    RuboCop::Config.new('Rails/RefuteMethods' => cop_config)
  end

  let(:cop_config) do
    {
      'EnforcedStyle' => enforced_style,
      'SupportedStyles' => %w[assert_not refute]
    }
  end

  context 'when EnforcedStyle is `assert_not`' do
    let(:enforced_style) { 'assert_not' }

    it 'registers an offense and correct using `refute` with a single argument' do
      expect_offense(<<~RUBY)
        refute foo
        ^^^^^^ Prefer `assert_not` over `refute`.
      RUBY

      expect_correction(<<~RUBY)
        assert_not foo
      RUBY
    end

    it 'registers an offense and corrects using `refute` with multiple arguments' do
      expect_offense(<<~RUBY)
        refute foo, bar, baz
        ^^^^^^ Prefer `assert_not` over `refute`.
      RUBY

      expect_correction(<<~RUBY)
        assert_not foo, bar, baz
      RUBY
    end

    it 'registers an offense when using `refute_empty`' do
      expect_offense(<<~RUBY)
        refute_empty foo
        ^^^^^^^^^^^^ Prefer `assert_not_empty` over `refute_empty`.
      RUBY

      expect_correction(<<~RUBY)
        assert_not_empty foo
      RUBY
    end

    it 'does not register an offense when using `assert_not` with a single argument' do
      expect_no_offenses(<<~RUBY)
        assert_not foo
      RUBY
    end

    it 'does not register an offense when using `assert_not` with a multiple arguments' do
      expect_no_offenses(<<~RUBY)
        assert_not foo, bar, baz
      RUBY
    end
  end

  context 'when EnforcedStyle is `refute`' do
    let(:enforced_style) { 'refute' }

    it 'registers an offense and correct using `assert_not` with a single argument' do
      expect_offense(<<~RUBY)
        assert_not foo
        ^^^^^^^^^^ Prefer `refute` over `assert_not`.
      RUBY

      expect_correction(<<~RUBY)
        refute foo
      RUBY
    end

    it 'registers an offense and corrects using `assert_not` with multiple arguments' do
      expect_offense(<<~RUBY)
        assert_not foo, bar, baz
        ^^^^^^^^^^ Prefer `refute` over `assert_not`.
      RUBY

      expect_correction(<<~RUBY)
        refute foo, bar, baz
      RUBY
    end

    it 'registers an offense when using `assert_not_empty`' do
      expect_offense(<<~RUBY)
        assert_not_empty foo
        ^^^^^^^^^^^^^^^^ Prefer `refute_empty` over `assert_not_empty`.
      RUBY

      expect_correction(<<~RUBY)
        refute_empty foo
      RUBY
    end

    it 'does not register an offense when using `refute` with a single argument' do
      expect_no_offenses(<<~RUBY)
        refute foo
      RUBY
    end

    it 'does not register an offense when using `refute` with a multiple arguments' do
      expect_no_offenses(<<~RUBY)
        refute foo, bar, baz
      RUBY
    end
  end
end
