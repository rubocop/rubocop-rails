# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ContentTag, :config do
  context 'Rails 5.0', :rails50 do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        content_tag(:p, 'Hello world!')
      RUBY
    end

    it 'does not register an offense with empty tag' do
      expect_no_offenses(<<~RUBY)
        content_tag(:br)
      RUBY
    end

    it 'does not register an offense with array of classnames' do
      expect_no_offenses(<<~RUBY)
        content_tag(:div, "Hello world!", class: ["strong", "highlight"])
      RUBY
    end

    it 'does not register an offense with nested content_tag' do
      expect_no_offenses(<<~RUBY)
        content_tag(:div) { content_tag(:strong, 'Hi') }

        content_tag(:div, content_tag(:span, 'foo'))
      RUBY
    end
  end

  context 'Rails 5.1', :rails51 do
    it 'corrects an offence' do
      expect_offense(<<~RUBY)
        content_tag(:p, 'Hello world!')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `tag` instead of `content_tag`.
      RUBY

      expect_correction(<<~RUBY)
        tag.p('Hello world!')
      RUBY
    end

    it 'corrects an offence with empty tag' do
      expect_offense(<<~RUBY)
        content_tag(:br)
        ^^^^^^^^^^^^^^^^ Use `tag` instead of `content_tag`.
      RUBY

      expect_correction(<<~RUBY)
        tag.br()
      RUBY
    end

    it 'corrects an offence with array of classnames' do
      expect_offense(<<~RUBY)
        content_tag(:div, "Hello world!", class: ["strong", "highlight"])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `tag` instead of `content_tag`.
      RUBY

      expect_correction(<<~RUBY)
        tag.div("Hello world!", class: ["strong", "highlight"])
      RUBY
    end

    it 'corrects an offence with nested content_tag' do
      expect_offense(<<~RUBY)
        content_tag(:div, content_tag(:span, 'foo'))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `tag` instead of `content_tag`.
      RUBY

      expect_correction(<<~RUBY)
        tag.div(tag.span('foo'))
      RUBY
    end

    it 'corrects an offence with nested content_tag with block' do
      expect_offense(<<~RUBY)
        content_tag(:div) { content_tag(:strong, 'Hi') }
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `tag` instead of `content_tag`.
        ^^^^^^^^^^^^^^^^^ Use `tag` instead of `content_tag`.
      RUBY

      expect_correction(<<~RUBY)
        tag.div() { tag.strong('Hi') }
      RUBY
    end

    it 'corrects an offence when first argument is hash' do
      expect_offense(<<~RUBY)
        content_tag({foo: 1})
        ^^^^^^^^^^^^^^^^^^^^^ Use `tag` instead of `content_tag`.
      RUBY

      expect_correction(<<~RUBY)
        tag({foo: 1})
      RUBY
    end

    it 'corrects an offence when first argument is non-identifier string' do
      expect_offense(<<~RUBY)
        content_tag('foo-bar', 'baz', class: 'strong')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `tag` instead of `content_tag`.
      RUBY

      expect_correction(<<~RUBY)
        tag.foo_bar('baz', class: 'strong')
      RUBY
    end

    it 'corrects an offense when called with options hash and block' do
      expect_offense(<<~RUBY)
        content_tag :div, { class: 'strong' } do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `tag` instead of `content_tag`.
          'body'
        end
      RUBY

      expect_correction(<<~RUBY)
        tag.div({ class: 'strong' }) do
          'body'
        end
      RUBY
    end

    it 'does not register an offence when `tag` is used with an argument' do
      expect_no_offenses(<<~RUBY)
        tag.p('Hello world!')
      RUBY
    end

    it 'does not register an offence when `tag` is used without arguments' do
      expect_no_offenses(<<~RUBY)
        tag.br
      RUBY
    end

    it 'does not register an offence when `tag` is used with arguments' do
      expect_no_offenses(<<~RUBY)
        tag.div("Hello world!", class: ["strong", "highlight"])
      RUBY
    end

    it 'does not register an offence when `tag` is nested' do
      expect_no_offenses(<<~RUBY)
        tag.div() { tag.strong('Hi') }
      RUBY
    end

    it 'does not register an offense when `content_tag` is called with no arguments' do
      expect_no_offenses(<<~RUBY)
        content_tag
      RUBY
    end

    context 'when the first argument is a variable' do
      it 'does not register an offence when the first argument is a lvar' do
        expect_no_offenses(<<~RUBY)
          name = do_something
          content_tag(name, "Hello world!", class: ["strong", "highlight"])
        RUBY
      end

      it 'does not register an offence when the first argument is an ivar' do
        expect_no_offenses(<<~RUBY)
          content_tag(@name, "Hello world!", class: ["strong", "highlight"])
        RUBY
      end

      it 'does not register an offence when the first argument is a cvar' do
        expect_no_offenses(<<~RUBY)
          content_tag(@@name, "Hello world!", class: ["strong", "highlight"])
        RUBY
      end

      it 'does not register an offence when the first argument is a gvar' do
        expect_no_offenses(<<~RUBY)
          content_tag($name, "Hello world!", class: ["strong", "highlight"])
        RUBY
      end

      it 'does not register an offence when the first argument is a splat argument' do
        expect_no_offenses(<<~RUBY)
          content_tag(*args, &block)
        RUBY
      end
    end

    context 'when the first argument is a method' do
      it 'does not register an offence' do
        expect_no_offenses(<<~RUBY)
          content_tag(name, "Hello world!", class: ["strong", "highlight"])
        RUBY
      end
    end

    context 'when the first argument is a constant' do
      it 'does not register an offence' do
        expect_no_offenses(<<~RUBY)
          content_tag(CONST, "Hello world!", class: ["strong", "highlight"])
        RUBY
      end
    end
  end
end
