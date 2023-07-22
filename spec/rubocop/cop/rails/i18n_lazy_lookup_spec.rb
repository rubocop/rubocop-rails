# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::I18nLazyLookup, :config do
  context 'when EnforcedStyle is lazy' do
    let(:cop_config) { { 'EnforcedStyle' => 'lazy' } }

    it 'registers an offense when using translation helpers with the key scoped to controller and action' do
      expect_offense(<<~RUBY)
        class FooController
          def action
            t 'foo.action.key'
              ^^^^^^^^^^^^^^^^ Use lazy lookup for the text used in controllers.
            translate 'foo.action.key'
                      ^^^^^^^^^^^^^^^^ Use lazy lookup for the text used in controllers.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class FooController
          def action
            t '.key'
            translate '.key'
          end
        end
      RUBY
    end

    it 'does not register an offense when translation methods scoped to `I18n`' do
      expect_no_offenses(<<~RUBY)
        class FooController
          def action
            I18n.t 'foo.action.key'
            I18n.translate 'foo.action.key'
          end
        end
      RUBY
    end

    it 'does not register an offense when not inside controller' do
      expect_no_offenses(<<~RUBY)
        class FooService
          def do_something
            t 'foo_service.do_something.key'
          end
        end
      RUBY
    end

    it 'does not register an offense when not inside controller action' do
      expect_no_offenses(<<~RUBY)
        class FooController
          private

          def action
            t 'foo.action.key'
          end
        end
      RUBY
    end

    it 'does not register an offense when translating key not scoped to controller and action' do
      expect_no_offenses(<<~RUBY)
        class FooController
          def action
            t 'one.two.key'
          end
        end
      RUBY
    end

    it 'does not register an offense when using "lazy" translation' do
      expect_no_offenses(<<~RUBY)
        class FooController
          def action
            t '.key'
          end
        end
      RUBY
    end

    it 'does not register an offense when translation key is not a string nor a symbol' do
      expect_no_offenses(<<~RUBY)
        class FooController
          def action
            t ['foo.action.key']
            t key
          end
        end
      RUBY
    end

    it 'handles scoped controllers' do
      expect_offense(<<~RUBY)
        module Bar
          class FooController
            def action
              t 'bar.foo.action.key'
                ^^^^^^^^^^^^^^^^^^^^ Use lazy lookup for the text used in controllers.
              t 'foo.action.key'
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Bar
          class FooController
            def action
              t '.key'
              t 'foo.action.key'
            end
          end
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is explicit' do
    let(:cop_config) { { 'EnforcedStyle' => 'explicit' } }

    it 'registers an offense and corrects when using "lazy" translation' do
      expect_offense(<<~RUBY)
        class FooController
          def action
            t '.key'
              ^^^^^^ Use explicit lookup for the text used in controllers.
            translate '.key'
                      ^^^^^^ Use explicit lookup for the text used in controllers.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class FooController
          def action
            t 'foo.action.key'
            translate 'foo.action.key'
          end
        end
      RUBY
    end

    it 'does not register an offense when using explicit translation keys' do
      expect_no_offenses(<<~RUBY)
        class FooController
          def action
            t 'foo.action.key'
          end
        end
      RUBY
    end

    it 'does not register an offense when translation key is not a string nor a symbol' do
      expect_no_offenses(<<~RUBY)
        class FooController
          def action
            t ['.key']
            t key
          end
        end
      RUBY
    end

    it 'handles scoped controllers' do
      expect_offense(<<~RUBY)
        module Bar
          class FooController
            def action
              t '.key'
                ^^^^^^ Use explicit lookup for the text used in controllers.
              t 'foo.action.key'
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Bar
          class FooController
            def action
              t 'bar.foo.action.key'
              t 'foo.action.key'
            end
          end
        end
      RUBY
    end
  end
end
