# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EnvironmentComparison, :config do
  context 'when comparing `Rails.env` to a string' do
    context 'when using equals' do
      it 'registers an offense and corrects when `Rails.env` is used on LHS' do
        expect_offense(<<~RUBY)
          Rails.env == 'production'
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `Rails.env.production?` over `Rails.env == 'production'`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.env.production?
        RUBY
      end

      it 'registers an offense and corrects when `Rails.env` is used on RHS' do
        expect_offense(<<~RUBY)
          'production' == Rails.env
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `Rails.env.production?` over `'production' == Rails.env`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.env.production?
        RUBY
      end
    end

    context 'when using not equals' do
      it 'registers an offense and corrects when `Rails.env` is used on LHS' do
        expect_offense(<<~RUBY)
          Rails.env != 'production'
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `!Rails.env.production?` over `Rails.env != 'production'`.
        RUBY

        expect_correction(<<~RUBY)
          !Rails.env.production?
        RUBY
      end

      it 'registers an offense and corrects when `Rails.env` is used on RHS' do
        expect_offense(<<~RUBY)
          'production' != Rails.env
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `!Rails.env.production?` over `'production' != Rails.env`.
        RUBY

        expect_correction(<<~RUBY)
          !Rails.env.production?
        RUBY
      end
    end
  end

  context 'when comparing `Rails.env` to a symbol' do
    context 'when using equals' do
      it 'registers an offense and corrects when `Rails.env` is used on LHS' do
        expect_offense(<<~RUBY)
          Rails.env == :production
          ^^^^^^^^^^^^^^^^^^^^^^^^ Do not compare `Rails.env` with a symbol, it will always evaluate to `false`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.env.production?
        RUBY
      end

      it 'registers an offense and corrects when `Rails.env` is used on RHS' do
        expect_offense(<<~RUBY)
          :production == Rails.env
          ^^^^^^^^^^^^^^^^^^^^^^^^ Do not compare `Rails.env` with a symbol, it will always evaluate to `false`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.env.production?
        RUBY
      end
    end

    context 'when using not equals' do
      it 'registers an offense and corrects when `Rails.env` is used on LHS' do
        expect_offense(<<~RUBY)
          Rails.env != :production
          ^^^^^^^^^^^^^^^^^^^^^^^^ Do not compare `Rails.env` with a symbol, it will always evaluate to `false`.
        RUBY

        expect_correction(<<~RUBY)
          !Rails.env.production?
        RUBY
      end

      it 'registers an offense and corrects when `Rails.env` is used on RHS' do
        expect_offense(<<~RUBY)
          :production != Rails.env
          ^^^^^^^^^^^^^^^^^^^^^^^^ Do not compare `Rails.env` with a symbol, it will always evaluate to `false`.
        RUBY

        expect_correction(<<~RUBY)
          !Rails.env.production?
        RUBY
      end
    end
  end

  context 'when comparing Rails.env using a case statement' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        case Rails.env
             ^^^^^^^^^ Favor environment check predicate methods over case comparison.
        when "production"
          do_production_thing
        when "staging"
          do_staging_thing
        else
          do_other_thing
        end
      RUBY
    end

    context 'with pattern matching' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          case Rails.env
               ^^^^^^^^^ Favor environment check predicate methods over case comparison.
          when "test" | "development"
            do_test_thing
          else
            do_other_thing
          end
        RUBY
      end
    end
  end

  it 'does not register an offense when using `#good_method`' do
    expect_no_offenses(<<~RUBY)
      Rails.env.production?
      Rails.env.test?
    RUBY
  end

  it 'does not register an offense for other case statements' do
    expect_no_offenses(<<~RUBY)
      case some_method
      when "test" | "development"
        do_test_thing
      else
        do_other_thing
      end
    RUBY
  end
end
