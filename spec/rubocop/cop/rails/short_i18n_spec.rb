# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ShortI18n, :config do
  shared_examples_for 'ShortI18n cop' do
    it 'registers an offense and corrects when using `I18n.translate`' do
      expect_offense(<<~RUBY)
        I18n.translate :key
             ^^^^^^^^^ Use `t` instead of `translate`.
      RUBY

      expect_correction(<<~RUBY)
        I18n.t :key
      RUBY
    end

    it 'registers an offense and corrects when using `::I18n.translate`' do
      expect_offense(<<~RUBY)
        ::I18n.translate :key
               ^^^^^^^^^ Use `t` instead of `translate`.
      RUBY

      expect_correction(<<~RUBY)
        ::I18n.t :key
      RUBY
    end

    it 'registers an offense and corrects when using `I18n.localize`' do
      expect_offense(<<~RUBY)
        I18n.localize Time.now
             ^^^^^^^^ Use `l` instead of `localize`.
      RUBY

      expect_correction(<<~RUBY)
        I18n.l Time.now
      RUBY
    end

    it 'registers an offense and corrects when using `::I18n.localize`' do
      expect_offense(<<~RUBY)
        ::I18n.localize Time.now
               ^^^^^^^^ Use `l` instead of `localize`.
      RUBY

      expect_correction(<<~RUBY)
        ::I18n.l Time.now
      RUBY
    end

    it 'does not register an offense when using `I18n.t`' do
      expect_no_offenses('I18n.t :key')
    end

    it 'does not register an offense when using `I18n.l`' do
      expect_no_offenses('I18n.l Time.now')
    end

    it 'does not register an offense when using `t`' do
      expect_no_offenses('t :key')
    end

    it 'does not register an offense when using `l`' do
      expect_no_offenses('l Time.now')
    end
  end

  context 'when EnforcedStyle set to conservative' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'conservative' }
    end

    it_behaves_like 'ShortI18n cop'

    it 'does not register an offense when using `translate`' do
      expect_no_offenses('translate :key')
    end

    it 'does not register an offense when using `localize`' do
      expect_no_offenses('localize Time.now')
    end
  end

  context 'when EnforcedStyle set to aggressive' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'aggressive' }
    end

    it_behaves_like 'ShortI18n cop'

    it 'registers an offense and corrects when using `translate`' do
      expect_offense(<<~RUBY)
        translate :key
        ^^^^^^^^^ Use `t` instead of `translate`.
      RUBY

      expect_correction(<<~RUBY)
        t :key
      RUBY
    end

    it 'registers an offense and corrects when using `localize`' do
      expect_offense(<<~RUBY)
        localize Time.now
        ^^^^^^^^ Use `l` instead of `localize`.
      RUBY

      expect_correction(<<~RUBY)
        l Time.now
      RUBY
    end
  end
end
