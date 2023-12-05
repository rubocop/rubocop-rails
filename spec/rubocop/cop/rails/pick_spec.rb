# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Pick, :config do
  context 'when using Rails 6.0 or newer', :rails60 do
    context 'with one argument' do
      it 'registers an offense for `pluck(...).first`' do
        expect_offense(<<~RUBY)
          x.pluck(:a).first
            ^^^^^^^^^^^^^^^ Prefer `pick(:a)` over `pluck(:a).first`.
        RUBY

        expect_correction(<<~RUBY)
          x.pick(:a)
        RUBY
      end

      it 'registers an offense for `pluck(...)&.first`' do
        expect_offense(<<~RUBY)
          x.pluck(:a)&.first
            ^^^^^^^^^^^^^^^^ Prefer `pick(:a)` over `pluck(:a)&.first`.
        RUBY

        expect_correction(<<~RUBY)
          x.pick(:a)
        RUBY
      end

      it 'registers an offense for `pluck(...)&.first` with safe navigation' do
        expect_offense(<<~RUBY)
          x&.pluck(:a)&.first
             ^^^^^^^^^^^^^^^^ Prefer `pick(:a)` over `pluck(:a)&.first`.
        RUBY

        expect_correction(<<~RUBY)
          x&.pick(:a)
        RUBY
      end
    end

    context 'with multiple arguments' do
      it 'registers an offense for `pluck(...).first`' do
        expect_offense(<<~RUBY)
          x.pluck(:a, :b).first
            ^^^^^^^^^^^^^^^^^^^ Prefer `pick(:a, :b)` over `pluck(:a, :b).first`.
        RUBY

        expect_correction(<<~RUBY)
          x.pick(:a, :b)
        RUBY
      end
    end
  end

  context 'when using Rails 5.2 or older', :rails52 do
    context 'with one argument' do
      it 'does not register an offense for `pluck(...).first`' do
        expect_no_offenses(<<~RUBY)
          x.pluck(:a).first
        RUBY
      end
    end

    context 'with multiple arguments' do
      it 'does not register an offense for `pluck(...).first`' do
        expect_no_offenses(<<~RUBY)
          x.pluck(:a, :b).first
        RUBY
      end
    end
  end
end
