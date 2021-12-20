# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::CompactBlank, :config do
  context 'Rails >= 6.1', :rails61 do
    it 'registers and corrects an offense when using `reject { |e| e.blank? }`' do
      expect_offense(<<~RUBY)
        collection.reject { |e| e.blank? }
                   ^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'registers and corrects an offense when using `reject { |e| e.empty? }`' do
      expect_offense(<<~RUBY)
        collection.reject { |e| e.empty? }
                   ^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'registers and corrects an offense when using `reject(&:blank?)`' do
      expect_offense(<<~RUBY)
        collection.reject(&:blank?)
                   ^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'registers and corrects an offense when using `reject(&:empty?)`' do
      expect_offense(<<~RUBY)
        collection.reject(&:empty?)
                   ^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'registers and corrects an offense when using `reject! { |e| e.blank? }`' do
      expect_offense(<<~RUBY)
        collection.reject! { |e| e.blank? }
                   ^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank!
      RUBY
    end

    it 'registers and corrects an offense when using `reject! { |e| e.empty? }`' do
      expect_offense(<<~RUBY)
        collection.reject! { |e| e.empty? }
                   ^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank!
      RUBY
    end

    it 'registers and corrects an offense when using `reject!(&:blank?)`' do
      expect_offense(<<~RUBY)
        collection.reject!(&:blank?)
                   ^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank!
      RUBY
    end

    it 'registers and corrects an offense when using `reject!(&:empty?)`' do
      expect_offense(<<~RUBY)
        collection.reject!(&:empty?)
                   ^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank!
      RUBY
    end

    it 'registers and corrects an offense when using `reject { |k, v| v.empty? }`' do
      expect_offense(<<~RUBY)
        collection.reject { |k, v| v.empty? }
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'does not register an offense when using `compact_blank`' do
      expect_no_offenses(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'does not register an offense when using `compact_blank!`' do
      expect_no_offenses(<<~RUBY)
        collection.compact_blank!
      RUBY
    end

    it 'does not register an offense when using `reject { |k, v| k.empty? }`' do
      expect_no_offenses(<<~RUBY)
        collection.reject { |k, v| k.empty? }
      RUBY
    end
  end

  context 'Rails <= 6.0', :rails60 do
    it 'does not register an offense when using `reject { |e| e.blank? }`' do
      expect_no_offenses(<<~RUBY)
        collection.reject { |e| e.blank? }
      RUBY
    end

    it 'does not register an offense when using `reject { |e| e.empty? }`' do
      expect_no_offenses(<<~RUBY)
        collection.reject { |e| e.empty? }
      RUBY
    end
  end
end
