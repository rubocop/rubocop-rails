# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ContentTag, :config do
  context 'Rails 5.0', :rails50 do
    it 'does not register an offense with method style' do
      expect_no_offenses(<<~RUBY)
        tag.br
      RUBY
    end

    it 'does not register an offense when `tag` is used with an argument' do
      expect_no_offenses(<<~RUBY)
        tag.p('Hello world!')
      RUBY
    end

    it 'does not register an offense when `tag` is used with arguments' do
      expect_no_offenses(<<~RUBY)
        tag.div("Hello world!", class: ["strong", "highlight"])
      RUBY
    end

    it 'does not register an offense when `tag` is nested' do
      expect_no_offenses(<<~RUBY)
        tag.div() { tag.strong('Hi') }
      RUBY
    end

    it 'does not register an offense with only tag name' do
      expect_no_offenses(<<~RUBY)
        tag(:br)
      RUBY
    end

    it 'does not register an offense with all arguments' do
      expect_no_offenses(<<~RUBY)
        tag(:br, {class: ["strong", "highlight"]}, true, false)
      RUBY
    end
  end

  context 'Rails 5.1', :rails51 do
    it 'does not register an offense when `tag` is used with an argument' do
      expect_no_offenses(<<~RUBY)
        tag.p('Hello world!')
      RUBY
    end

    it 'does not register an offense when `tag` is used without arguments' do
      expect_no_offenses(<<~RUBY)
        tag.br
      RUBY
    end

    it 'does not register an offense when `tag` is used with arguments' do
      expect_no_offenses(<<~RUBY)
        tag.div("Hello world!", class: ["strong", "highlight"])
      RUBY
    end

    it 'does not register an offense when `tag` is nested' do
      expect_no_offenses(<<~RUBY)
        tag.div() { tag.strong('Hi') }
      RUBY
    end

    it 'corrects an offense with only tag name' do
      expect_offense(<<~RUBY)
        tag(:br)
        ^^^^^^^^ Use `tag.br` instead of `tag(:br)`.
      RUBY

      expect_correction(<<~RUBY)
        tag.br()
      RUBY
    end

    # Prevents `ArgumentError` reported by https://github.com/rubocop/rubocop-rails/issues/556.
    # See: https://api.rubyonrails.org/v6.1.4/classes/ActionView/Helpers/TagHelper.html#method-i-tag-label-Legacy+syntax
    it 'does not register an offense with all arguments' do
      expect_no_offenses(<<~RUBY)
        tag(:br, {class: ["strong", "highlight"]}, true, false)
      RUBY
    end

    # Prevents `ArgumentError` reported by https://github.com/rubocop/rubocop-rails/issues/556.
    # See: https://api.rubyonrails.org/v6.1.4/classes/ActionView/Helpers/TagHelper.html#method-i-tag-label-Legacy+syntax
    it 'does not register an offense with three arguments' do
      expect_no_offenses(<<~RUBY)
        tag(:br, {class: ["strong", "highlight"]}, true)
      RUBY
    end

    it 'corrects an offense when first argument is non-identifier string' do
      expect_offense(<<~RUBY)
        tag('foo-bar', class: 'strong')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `tag.foo_bar` instead of `tag('foo-bar')`.
      RUBY

      expect_correction(<<~RUBY)
        tag.foo_bar(class: 'strong')
      RUBY
    end

    it 'does not register an offense when first argument is snake case string' do
      expect_no_offenses(<<~RUBY)
        tag('foo_bar', class: 'strong')
      RUBY
    end

    it 'corrects an offense when first argument is string starts with hyphen' do
      expect_offense(<<~RUBY)
        tag('-foo', class: 'strong')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `tag._foo` instead of `tag('-foo')`.
      RUBY

      expect_correction(<<~RUBY)
        tag._foo(class: 'strong')
      RUBY
    end

    it 'does not register an offense when first argument is a string which starts with an underscore' do
      expect_no_offenses(<<~RUBY)
        tag('_foo', class: 'strong')
      RUBY
    end

    context 'when the first argument is a variable' do
      it 'does not register an offense when the first argument is a lvar' do
        expect_no_offenses(<<~RUBY)
          name = do_something
          tag(name, class: ["strong", "highlight"])
        RUBY
      end

      it 'does not register an offense when the first argument is an ivar' do
        expect_no_offenses(<<~RUBY)
          tag(@name, class: ["strong", "highlight"])
        RUBY
      end

      it 'does not register an offense when the first argument is a cvar' do
        expect_no_offenses(<<~RUBY)
          tag(@@name, class: ["strong", "highlight"])
        RUBY
      end

      it 'does not register an offense when the first argument is a gvar' do
        expect_no_offenses(<<~RUBY)
          tag($name, class: ["strong", "highlight"])
        RUBY
      end

      it 'does not register an offense when the first argument is a splat argument' do
        expect_no_offenses(<<~RUBY)
          tag(*args)
        RUBY
      end
    end

    context 'when the first argument is a method' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          tag(name, class: ["strong", "highlight"])
        RUBY
      end
    end

    context 'when the first argument is a constant' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          tag(CONST, class: ["strong", "highlight"])
        RUBY
      end
    end

    context 'when the first argument is keyword arguments' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          tag(factory: :tag)
        RUBY
      end
    end

    context 'when `tag` is not a top-level method (e.g. using intercom-ruby)' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          intercom.tags.tag(foo: 'foo', bar: 'bar')
        RUBY
      end
    end
  end
end
