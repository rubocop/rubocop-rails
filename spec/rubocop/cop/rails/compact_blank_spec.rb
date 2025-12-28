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

    it 'registers and corrects an offense when using `reject(&:blank?)`' do
      expect_offense(<<~RUBY)
        collection.reject(&:blank?)
                   ^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'registers and corrects an offense when using `reject { |k, v| v.blank? }`' do
      expect_offense(<<~RUBY)
        collection.reject { |k, v| v.blank? }
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'registers and corrects an offense when using `delete_if { |e| e.blank? }`' do
      expect_offense(<<~RUBY)
        collection.delete_if { |e| e.blank? }
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank!
      RUBY
    end

    it 'registers and corrects an offense when using `delete_if(&:blank?)`' do
      expect_offense(<<~RUBY)
        collection.delete_if(&:blank?)
                   ^^^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank!
      RUBY
    end

    it 'registers and corrects an offense when using `delete_if { |k, v| v.blank? }`' do
      expect_offense(<<~RUBY)
        collection.delete_if { |k, v| v.blank? }
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank!
      RUBY
    end

    it 'does not register an offense when using `reject! { |e| e.blank? }`' do
      expect_no_offenses(<<~RUBY)
        collection.reject! { |e| e.blank? }
      RUBY
    end

    it 'does not register an offense when using `reject!(&:blank?)`' do
      expect_no_offenses(<<~RUBY)
        collection.reject!(&:blank?)
      RUBY
    end

    it 'registers and corrects an offense when using `reject(&:blank?)` in block' do
      expect_offense(<<~RUBY)
        hash.transform_values { |value| value.reject(&:blank?) }
                                              ^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        hash.transform_values { |value| value.compact_blank }
      RUBY
    end

    it 'registers and corrects an offense when using `select { |e| e.present? }`' do
      expect_offense(<<~RUBY)
        collection.select { |e| e.present? }
                   ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'registers and corrects an offense when using `select(&:present?)`' do
      expect_offense(<<~RUBY)
        collection.select(&:present?)
                   ^^^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'registers and corrects an offense when using `select { |k, v| v.present? }`' do
      expect_offense(<<~RUBY)
        collection.select { |k, v| v.present? }
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'registers and corrects an offense when using `filter { |e| e.present? }`' do
      expect_offense(<<~RUBY)
        collection.filter { |e| e.present? }
                   ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'registers and corrects an offense when using `filter(&:present?)`' do
      expect_offense(<<~RUBY)
        collection.filter(&:present?)
                   ^^^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'registers and corrects an offense when using `filter { |k, v| v.present? }`' do
      expect_offense(<<~RUBY)
        collection.filter { |k, v| v.present? }
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank
      RUBY
    end

    it 'registers and corrects an offense when using `keep_if { |e| e.present? }`' do
      expect_offense(<<~RUBY)
        collection.keep_if { |e| e.present? }
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank!
      RUBY
    end

    it 'registers and corrects an offense when using `keep_if(&:present?)`' do
      expect_offense(<<~RUBY)
        collection.keep_if(&:present?)
                   ^^^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank!
      RUBY
    end

    it 'registers and corrects an offense when using `keep_if { |k, v| v.present? }`' do
      expect_offense(<<~RUBY)
        collection.keep_if { |k, v| v.present? }
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
      RUBY

      expect_correction(<<~RUBY)
        collection.compact_blank!
      RUBY
    end

    it 'does not register an offense when using `select! { |e| e.present? }`' do
      expect_no_offenses(<<~RUBY)
        collection.select! { |e| e.present? }
      RUBY
    end

    it 'does not register an offense when using `select!(&:present?)`' do
      expect_no_offenses(<<~RUBY)
        collection.select!(&:present?)
      RUBY
    end

    it 'does not register an offense when using `filter! { |e| e.present? }`' do
      expect_no_offenses(<<~RUBY)
        collection.filter! { |e| e.present? }
      RUBY
    end

    it 'does not register an offense when using `filter!(&:present?)`' do
      expect_no_offenses(<<~RUBY)
        collection.filter!(&:present?)
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

    it 'does not register an offense when using `reject { |k, v| k.blank? }`' do
      expect_no_offenses(<<~RUBY)
        collection.reject { |k, v| k.blank? }
      RUBY
    end

    it 'does not register an offense when using the receiver of `blank?` is not a block variable' do
      expect_no_offenses(<<~RUBY)
        def foo(arg)
          collection.reject { |_| arg.blank? }
        end
      RUBY
    end

    it 'does not register an offense when using `reject { |e| e.empty? }`' do
      expect_no_offenses(<<~RUBY)
        collection.reject { |e| e.empty? }
      RUBY
    end

    it 'does not register an offense when using `select { |e| e.blank? }`' do
      expect_no_offenses(<<~RUBY)
        collection.select { |e| e.blank? }
      RUBY
    end

    it 'does not register an offense when using `filter { |e| e.blank? }`' do
      expect_no_offenses(<<~RUBY)
        collection.filter { |e| e.blank? }
      RUBY
    end

    context 'target_ruby_version >= 2.6', :ruby26 do
      it 'registers and corrects an offense when using `filter { |e| e.present? }`' do
        expect_offense(<<~RUBY)
          collection.filter { |e| e.present? }
                     ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
        RUBY

        expect_correction(<<~RUBY)
          collection.compact_blank
        RUBY
      end
    end

    context 'target_ruby_version < 2.6', :ruby25, unsupported_on: :prism do
      it 'does not register an offense when using `filter { |e| e.present? }`' do
        expect_no_offenses(<<~RUBY)
          collection.filter { |e| e.present? }
        RUBY
      end
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

    it 'does not register an offense when using `select { |e| e.present? }`' do
      expect_no_offenses(<<~RUBY)
        collection.select { |e| e.present? }
      RUBY
    end

    it 'does not register an offense when using `filter { |e| e.present? }`' do
      expect_no_offenses(<<~RUBY)
        collection.filter { |e| e.present? }
      RUBY
    end
  end
end
