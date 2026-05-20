# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DelegateVisibilityMismatch, :config do
  let(:private_msg) { 'Match the `private:` option on `delegate` to the enclosing `private` visibility scope.' }
  let(:protected_msg) { 'Match the `private:` option on `delegate` to the enclosing `protected` visibility scope.' }
  let(:public_msg) { 'Match the `private:` option on `delegate` to the enclosing `public` visibility scope.' }

  context 'when `delegate` appears after a bare `private` and is missing `private: true`' do
    it 'registers an offense and autocorrects by appending `private: true`' do
      expect_offense(<<~RUBY)
        class Foo
          private

          delegate :bar, to: :baz
          ^^^^^^^^^^^^^^^^^^^^^^^ #{private_msg}
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          private

          delegate :bar, to: :baz, private: true
        end
      RUBY
    end
  end

  context 'when multiple arguments are delegated under `private`' do
    it 'registers an offense and autocorrects' do
      expect_offense(<<~RUBY)
        class Foo
          private

          delegate :bar, :baz, to: :qux, allow_nil: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{private_msg}
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          private

          delegate :bar, :baz, to: :qux, allow_nil: true, private: true
        end
      RUBY
    end
  end

  context 'when `delegate` already has `private: true`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
          private

          delegate :bar, to: :baz, private: true
        end
      RUBY
    end
  end

  context 'when `delegate` has `private: false` under a `private` modifier' do
    it 'registers an offense and flips the value to true' do
      expect_offense(<<~RUBY)
        class Foo
          private

          delegate :bar, to: :baz, private: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{private_msg}
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          private

          delegate :bar, to: :baz, private: true
        end
      RUBY
    end
  end

  context 'when `delegate` appears in the public section of a class' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
          delegate :bar, to: :baz
        end
      RUBY
    end
  end

  context 'when `delegate` has `private: false` under `public`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
          delegate :bar, to: :baz, private: false
        end
      RUBY
    end
  end

  context 'when `delegate` has `private: true` with no explicit visibility modifier' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
          delegate :bar, to: :baz, private: true
        end
      RUBY
    end
  end

  context 'when `delegate` has `private: true` under an explicit `public` modifier' do
    it 'registers an offense and flips the value to false' do
      expect_offense(<<~RUBY)
        class Foo
          public

          delegate :bar, to: :baz, private: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{public_msg}
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          public

          delegate :bar, to: :baz, private: false
        end
      RUBY
    end
  end

  context 'when `delegate` has `private: true` after `public` restores visibility' do
    it 'registers an offense and flips the value to false' do
      expect_offense(<<~RUBY)
        class Foo
          private

          def internal; end

          public

          delegate :bar, to: :baz, private: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{public_msg}
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          private

          def internal; end

          public

          delegate :bar, to: :baz, private: false
        end
      RUBY
    end
  end

  context 'when `delegate` follows `private` but a later `public` restores visibility' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
          private

          def internal; end

          public

          delegate :bar, to: :baz
        end
      RUBY
    end
  end

  context 'when `delegate` is preceded by `protected` and is missing `private: true`' do
    it 'registers an offense and autocorrects to `private: true`' do
      expect_offense(<<~RUBY)
        class Foo
          protected

          delegate :bar, to: :baz
          ^^^^^^^^^^^^^^^^^^^^^^^ #{protected_msg}
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          protected

          delegate :bar, to: :baz, private: true
        end
      RUBY
    end
  end

  context 'when `delegate` under `protected` has `private: false`' do
    it 'registers an offense and flips to `private: true`' do
      expect_offense(<<~RUBY)
        class Foo
          protected

          delegate :bar, to: :baz, private: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{protected_msg}
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          protected

          delegate :bar, to: :baz, private: true
        end
      RUBY
    end
  end

  context 'when `private :method_name` is used with an argument' do
    it 'does not consider it a scope change' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def internal; end
          private :internal

          delegate :bar, to: :baz
        end
      RUBY
    end
  end

  context 'when `delegate` is defined inside a module under a `private` modifier' do
    it 'registers an offense and autocorrects' do
      expect_offense(<<~RUBY)
        module Foo
          private

          delegate :bar, to: :baz
          ^^^^^^^^^^^^^^^^^^^^^^^ #{private_msg}
        end
      RUBY

      expect_correction(<<~RUBY)
        module Foo
          private

          delegate :bar, to: :baz, private: true
        end
      RUBY
    end
  end

  context 'when the delegate is spread across multiple lines under `private`' do
    it 'registers an offense and autocorrects by appending `private: true`' do
      expect_offense(<<~RUBY)
        class Foo
          private

          delegate :bar,
          ^^^^^^^^^^^^^^ #{private_msg}
            :qux,
            to: :baz
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          private

          delegate :bar,
            :qux,
            to: :baz, private: true
        end
      RUBY
    end
  end
end
