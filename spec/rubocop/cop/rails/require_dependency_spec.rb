# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RequireDependency, :config do
  context 'when require' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        require 'foo'
      RUBY
    end
  end

  context 'when require_relative' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        require_relative 'foo'
      RUBY
    end
  end

  context 'when require_dependency' do
    context 'when using Rails 6.0 or newer', :rails60 do
      context 'without receiver' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            require_dependency 'foo'
            ^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `require_dependency` with Zeitwerk mode.
          RUBY
        end
      end

      context 'with `Kernel` as receiver' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            Kernel.require_dependency 'foo'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `require_dependency` with Zeitwerk mode.
          RUBY
        end
      end

      context 'with `::Kernel` as receiver' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            ::Kernel.require_dependency 'foo'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `require_dependency` with Zeitwerk mode.
          RUBY
        end
      end

      context 'with `Foo::Kernel` as receiver' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            Foo::Kernel.require_dependency 'foo'
          RUBY
        end
      end
    end

    context 'when using Rails 5.2 or older', :rails52 do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          require_dependency 'foo'
        RUBY
      end
    end
  end
end
