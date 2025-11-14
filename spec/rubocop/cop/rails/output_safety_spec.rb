# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::OutputSafety, :config do
  context 'when using `#safe_concat`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        foo.safe_concat('bar')
            ^^^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense when wrapped inside `#safe_join`' do
      expect_offense(<<~RUBY)
        safe_join([i18n_text.safe_concat(i18n_text)])
                             ^^^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          foo&.safe_concat('bar')
               ^^^^^^^^^^^ Tagging a string as html safe may be a security risk.
        RUBY
      end
    end
  end

  context 'when using `#html_safe`' do
    it 'does not register an offense for static string literal receiver' do
      expect_no_offenses(<<~RUBY)
        "foo".html_safe
      RUBY
    end

    it 'registers an offense for dynamic string literal receiver' do
      expect_offense(<<~'RUBY')
        "foo#{1}".html_safe
                  ^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'does not register an offense for static single line heredoc receiver' do
      expect_no_offenses(<<~RUBY)
        <<~HTML.html_safe
          foo
        HTML
      RUBY
    end

    it 'registers an offense for dynamic single line heredoc receiver' do
      expect_offense(<<~'RUBY')
        <<~HTML.html_safe
                ^^^^^^^^^ Tagging a string as html safe may be a security risk.
          #{foo}
        HTML
      RUBY
    end

    it 'does not register an offense for static multiline heredoc receiver' do
      expect_no_offenses(<<~RUBY)
        <<~HTML.html_safe
          foo
          bar
        HTML
      RUBY
    end

    it 'registers an offense for dynamic multiline heredoc receiver' do
      expect_offense(<<~'RUBY')
        <<~HTML.html_safe
                ^^^^^^^^^ Tagging a string as html safe may be a security risk.
          foo
          #{bar}
        HTML
      RUBY
    end

    it 'registers an offense for variable receiver' do
      expect_offense(<<~RUBY)
        foo.html_safe
            ^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'does not register an offense for variable receiver and arguments' do
      expect_no_offenses(<<~RUBY)
        foo.html_safe(one)
      RUBY
    end

    it 'does not register an offense without a receiver' do
      expect_no_offenses('html_safe')
    end

    it 'registers an offense when used inside `#safe_join`' do
      expect_offense(<<~RUBY)
        safe_join([i18n_text.html_safe, "foo"])
                             ^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense when used inside `#safe_join` in other method' do
      expect_offense(<<~RUBY)
        foo(safe_join([i18n_text.html_safe, "bar"]))
                                 ^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense for variable receiver and no argument' do
        expect_offense(<<~RUBY)
          foo&.html_safe
               ^^^^^^^^^ Tagging a string as html safe may be a security risk.
        RUBY
      end
    end
  end

  context 'when using `#raw`' do
    it 'registers an offense with no receiver and a variable argument' do
      expect_offense(<<~RUBY)
        raw(foo)
        ^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense with no receiver and a literal argument' do
      expect_offense(<<~RUBY)
        raw("foo")
        ^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'does not register an offense with a receiver' do
      expect_no_offenses(<<~RUBY)
        foo.raw(foo)
      RUBY
    end

    it 'does not register an offense without arguments' do
      expect_no_offenses('raw')
    end

    it 'does not register an offense with more than one argument' do
      expect_no_offenses('raw(one, two)')
    end

    it 'does not register an offense for comments' do
      expect_no_offenses(<<~RUBY)
        # foo.html_safe
        # raw foo
      RUBY
    end

    it 'registers an offense when used inside `#safe_join`' do
      expect_offense(<<~RUBY)
        safe_join([raw(i18n_text), "foo"])
                   ^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense when used inside `#safe_join` in other method' do
      expect_offense(<<~RUBY)
        foo(safe_join([raw(i18n_text), "bar"]))
                       ^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'does not register an offense when using `html_safe` for `I18n.t` method' do
      expect_no_offenses(<<~RUBY)
        I18n.t('foo.bar.baz', scope: [:x, :y, :z]).html_safe
        ::I18n.t('foo.bar.baz', scope: [:x, :y, :z]).html_safe
      RUBY
    end

    it 'does not register an offense when using `html_safe` for `I18n.translate` method' do
      expect_no_offenses(<<~RUBY)
        I18n.translate('foo.bar.baz', scope: [:x, :y, :z]).html_safe
        ::I18n.translate('foo.bar.baz', scope: [:x, :y, :z]).html_safe
      RUBY
    end

    it 'does not register an offense when using `html_safe` for `t` method' do
      expect_no_offenses(<<~RUBY)
        t('foo.bar.baz').html_safe
      RUBY
    end

    it 'does not register an offense when using `html_safe` for `translate` method' do
      expect_no_offenses(<<~RUBY)
        translate('foo.bar.baz').html_safe
      RUBY
    end

    it 'does not register an offense when using `html_safe` for `I18n.l` method' do
      expect_no_offenses(<<~RUBY)
        I18n.l(Time.now, locale: :de).html_safe
        ::I18n.l(Time.now, locale: :de).html_safe
      RUBY
    end

    it 'does not register an offense when using `html_safe` for `I18n.localize` method' do
      expect_no_offenses(<<~RUBY)
        I18n.localize(Time.now, locale: :de).html_safe
        ::I18n.localize(Time.now, locale: :de).html_safe
      RUBY
    end

    it 'does not register an offense when using `html_safe` for `l` method' do
      expect_no_offenses(<<~RUBY)
        l(Time.now).html_safe
      RUBY
    end

    it 'does not register an offense when using `html_safe` for `localize` method' do
      expect_no_offenses(<<~RUBY)
        localize(Time.now).html_safe
      RUBY
    end
  end
end
