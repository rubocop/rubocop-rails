# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::IndexBy, :config do
  context 'with an inline block' do
    it 'registers an offense for `each_with_object`' do
      expect_offense(<<~RUBY)
        x.each_with_object({}) { |el, h| h[foo(el)] = el }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `index_by` over `each_with_object`.
      RUBY

      expect_correction(<<~RUBY)
        x.index_by { |el| foo(el) }
      RUBY
    end
  end

  context 'with a multiline block' do
    it 'registers an offense for `each_with_object`' do
      expect_offense(<<~RUBY)
        x.each_with_object({}) do |el, memo|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `index_by` over `each_with_object`.
          memo[el.to_sym] = el
        end
      RUBY

      expect_correction(<<~RUBY)
        x.index_by do |el|
          el.to_sym
        end
      RUBY
    end
  end

  context 'with safe navigation operator' do
    it 'registers an offense for `each_with_object`' do
      expect_offense(<<~RUBY)
        x&.each_with_object({}) { |el, h| h[foo(el)] = el }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `index_by` over `each_with_object`.
      RUBY

      expect_correction(<<~RUBY)
        x&.index_by { |el| foo(el) }
      RUBY
    end
  end

  context 'when values are transformed' do
    it 'does not register an offense for `each_with_object`' do
      expect_no_offenses(<<~RUBY)
        x.each_with_object({}) { |el, h| h[el.to_sym] = foo(el) }
      RUBY
    end
  end

  context 'when keys are not transformed' do
    it 'does not register an offense for `each_with_object`' do
      expect_no_offenses('x.each_with_object({}) { |el, h| h[el] = el }')
    end
  end

  context 'when the given hash is not used' do
    it 'does not register an offense for `each_with_object`' do
      expect_no_offenses(<<~RUBY)
        x.each_with_object({}) { |el, h| other_h[el.to_sym] = el }
      RUBY
    end
  end

  context 'when the given hash is used in the key' do
    it 'does not register an offense for `each_with_object`' do
      expect_no_offenses(<<~RUBY)
        x.each_with_object({}) { |el, h| h[h[el]] = el }
      RUBY
    end
  end

  context 'when `to_h` is given a block' do
    it 'registers an offense for `map { ... }.to_h`' do
      expect_offense(<<~RUBY)
        x.map { |el| [el.to_sym, el] }.to_h { |k, v| [v, k] }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `index_by` over `map { ... }.to_h`.
      RUBY

      expect_correction(<<~RUBY)
        x.index_by { |el| el.to_sym }.to_h { |k, v| [v, k] }
      RUBY
    end
  end

  context 'when `to_h` is not given a block' do
    it 'registers an offense for `map { ... }.to_h`' do
      expect_offense(<<~RUBY)
        x.map { |el| [el.to_sym, el] }.to_h
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `index_by` over `map { ... }.to_h`.
      RUBY

      expect_correction(<<~RUBY)
        x.index_by { |el| el.to_sym }
      RUBY
    end
  end

  context 'when `to_h` is on a different line' do
    it 'registers an offense for `map { ... }.to_h`' do
      expect_offense(<<~RUBY)
        x.map { |el| [el.to_sym, el] }.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `index_by` over `map { ... }.to_h`.
          to_h
      RUBY

      expect_correction(<<~RUBY)
        x.index_by { |el| el.to_sym }
      RUBY
    end
  end

  context 'when `.to_h` is on a different line' do
    it 'registers an offense for `map { ... }.to_h`' do
      expect_offense(<<~RUBY)
        x.map { |el| [el.to_sym, el] }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `index_by` over `map { ... }.to_h`.
          .to_h
      RUBY

      expect_correction(<<~RUBY)
        x.index_by { |el| el.to_sym }
      RUBY
    end
  end

  context 'when to_h is not called on the result' do
    it 'does not register an offense for `map { ... }.to_h`' do
      expect_no_offenses('x.map { |el| [el.to_sym, el] }')
    end
  end

  it 'registers an offense for `Hash[map { ... }]`' do
    expect_offense(<<~RUBY)
      Hash[x.map { |el| [el.to_sym, el] }]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `index_by` over `Hash[map { ... }]`.
    RUBY

    expect_correction(<<~RUBY)
      x.index_by { |el| el.to_sym }
    RUBY
  end

  it 'registers an offense for `::Hash[map { ... }]`' do
    expect_offense(<<~RUBY)
      ::Hash[x.map { |el| [el.to_sym, el] }]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `index_by` over `Hash[map { ... }]`.
    RUBY

    expect_correction(<<~RUBY)
      x.index_by { |el| el.to_sym }
    RUBY
  end

  it 'does not register an offense for `Foo::Hash[map { ... }]`' do
    expect_no_offenses(<<~RUBY)
      Foo::Hash[x.map { |el| [el.to_sym, el] }]
    RUBY
  end

  context 'when using Ruby 2.6 or newer', :ruby26 do
    it 'registers an offense for `to_h { ... }`' do
      expect_offense(<<~RUBY)
        x.to_h { |el| [el.to_sym, el] }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `index_by` over `to_h { ... }`.
      RUBY

      expect_correction(<<~RUBY)
        x.index_by { |el| el.to_sym }
      RUBY
    end
  end

  context 'when using Ruby 2.5 or older', :ruby25, unsupported_on: :prism do
    it 'does not register an offense for `to_h { ... }`' do
      expect_no_offenses(<<~RUBY)
        x.to_h { |el| [el.to_sym, el] }
      RUBY
    end
  end
end
