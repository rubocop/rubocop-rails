# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::StripHeredoc, :config do
  context 'Ruby <= 2.2', :ruby22, unsupported_on: :prism do
    it 'does not register an offense when using `strip_heredoc`' do
      expect_no_offenses(<<~RUBY)
        <<-EOS.strip_heredoc
          some text
        EOS
      RUBY
    end
  end

  context 'Ruby >= 2.3', :ruby23 do
    it 'registers an offense when using `strip_heredoc` with `<<`' do
      expect_offense(<<~RUBY)
        <<EOS.strip_heredoc
        ^^^^^^^^^^^^^^^^^^^ Use squiggly heredoc (`<<~`) instead of `strip_heredoc`.
          some text
        EOS
      RUBY

      expect_correction(<<~RUBY)
        <<~EOS
          some text
        EOS
      RUBY
    end

    it 'registers an offense when using `strip_heredoc` with `<<-`' do
      expect_offense(<<~RUBY)
        <<-EOS.strip_heredoc
        ^^^^^^^^^^^^^^^^^^^^ Use squiggly heredoc (`<<~`) instead of `strip_heredoc`.
          some text
        EOS
      RUBY

      expect_correction(<<~RUBY)
        <<~EOS
          some text
        EOS
      RUBY
    end

    it 'registers an offense when using `strip_heredoc.do_something`' do
      expect_offense(<<~RUBY)
        <<-EOS.strip_heredoc.do_something
        ^^^^^^^^^^^^^^^^^^^^ Use squiggly heredoc (`<<~`) instead of `strip_heredoc`.
          some text
        EOS
      RUBY

      expect_correction(<<~RUBY)
        <<~EOS.do_something
          some text
        EOS
      RUBY
    end

    it 'registers an offense when using `strip_heredoc` with multiline text' do
      expect_offense(<<~RUBY)
        <<-EOS.strip_heredoc
        ^^^^^^^^^^^^^^^^^^^^ Use squiggly heredoc (`<<~`) instead of `strip_heredoc`.
          some text
          some text
        EOS
      RUBY

      expect_correction(<<~RUBY)
        <<~EOS
          some text
          some text
        EOS
      RUBY
    end

    it 'registers an offense when squiggly already present' do
      expect_offense(<<~RUBY)
        <<~EOS.strip_heredoc
        ^^^^^^^^^^^^^^^^^^^^ Use squiggly heredoc (`<<~`) instead of `strip_heredoc`.
          some text
        EOS
      RUBY

      expect_correction(<<~RUBY)
        <<~EOS
          some text
        EOS
      RUBY
    end

    it 'does not register an offense when using squiggly heredoc' do
      expect_no_offenses(<<~RUBY)
        <<~EOS
          some text
        EOS
      RUBY
    end

    it 'does not register an offense when using `do_something.strip_heredoc`' do
      expect_no_offenses(<<~RUBY)
        <<-EOS.do_something.strip_heredoc
          some text
        EOS
      RUBY
    end

    it 'does not register an offense when using `strip_heredoc` without receiver' do
      expect_no_offenses(<<~RUBY)
        strip_heredoc
      RUBY
    end
  end
end
