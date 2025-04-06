# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::HashLiteralKeysConversion, :config do
  it 'registers an offense and corrects when using `symbolize_keys` with only symbol keys' do
    expect_offense(<<~RUBY)
      { a: 1, b: 2 }.symbolize_keys
                     ^^^^^^^^^^^^^^ Redundant hash keys conversion, all the keys have the required type.
    RUBY

    expect_correction(<<~RUBY)
      { a: 1, b: 2 }
    RUBY
  end

  it 'registers an offense and corrects when using `symbolize_keys` with only symbol and string keys' do
    expect_offense(<<~RUBY)
      { a: 1, 'b' => 2 }.symbolize_keys
                         ^^^^^^^^^^^^^^ Convert hash keys explicitly to the required type.
    RUBY

    expect_correction(<<~RUBY)
      { a: 1, :b => 2 }
    RUBY
  end

  it 'does not register an offense when using `symbolize_keys` with integer keys' do
    expect_no_offenses(<<~RUBY)
      { a: 1, 2 => 3 }.symbolize_keys
    RUBY
  end

  it 'does not register an offense when using `symbolize_keys` with non hash literal receiver' do
    expect_no_offenses(<<~RUBY)
      options.symbolize_keys
    RUBY
  end

  it 'registers an offense and corrects when using `stringify_keys` with only string keys' do
    expect_offense(<<~RUBY)
      { 'a' => 1, 'b' => 2 }.stringify_keys
                             ^^^^^^^^^^^^^^ Redundant hash keys conversion, all the keys have the required type.
    RUBY

    expect_correction(<<~RUBY)
      { 'a' => 1, 'b' => 2 }
    RUBY
  end

  it 'registers an offense and corrects when using `stringify_keys` with only symbol and string keys' do
    expect_offense(<<~RUBY)
      { a: 1, 'b' => 2 }.stringify_keys
                         ^^^^^^^^^^^^^^ Convert hash keys explicitly to the required type.
    RUBY

    expect_correction(<<~RUBY)
      { 'a'=> 1, 'b' => 2 }
    RUBY
  end

  it 'does not register an offense when using `stringify_keys` with integer keys' do
    expect_no_offenses(<<~RUBY)
      { 'a' => 1, 2 => 3 }.stringify_keys
    RUBY
  end

  it 'does not register an offense when using `stringify_keys` with non hash literal receiver' do
    expect_no_offenses(<<~RUBY)
      options.stringify_keys
    RUBY
  end

  it 'registers an offense and corrects when using `deep_symbolize_keys` with symbol keys' do
    expect_offense(<<~RUBY)
      {
        a: 1,
        b: {
          c: 1
        }
      }.deep_symbolize_keys
        ^^^^^^^^^^^^^^^^^^^ Redundant hash keys conversion, all the keys have the required type.
    RUBY

    expect_correction(<<~RUBY)
      {
        a: 1,
        b: {
          c: 1
        }
      }
    RUBY
  end

  it 'registers an offense and corrects when using `deep_symbolize_keys` with symbol and string keys' do
    expect_offense(<<~RUBY)
      {
        'a' => 1,
        b: {
          c: 1
        }
      }.deep_symbolize_keys
        ^^^^^^^^^^^^^^^^^^^ Convert hash keys explicitly to the required type.
    RUBY

    expect_correction(<<~RUBY)
      {
        :a => 1,
        b: {
          c: 1
        }
      }
    RUBY
  end

  it 'registers an offense and corrects when using `deep_symbolize_keys` with flat and only symbol and string keys' do
    expect_offense(<<~RUBY)
      {
        'a' => 1,
        b: 2
      }.deep_symbolize_keys
        ^^^^^^^^^^^^^^^^^^^ Convert hash keys explicitly to the required type.
    RUBY

    expect_correction(<<~RUBY)
      {
        :a => 1,
        b: 2
      }
    RUBY
  end

  it 'registers an offense and corrects when using `deep_symbolize_keys` with nested array' do
    expect_offense(<<~RUBY)
      {
        'a' => 1,
        b: [
          'c' => 2
        ]
      }.deep_symbolize_keys
        ^^^^^^^^^^^^^^^^^^^ Convert hash keys explicitly to the required type.
    RUBY

    expect_correction(<<~RUBY)
      {
        :a => 1,
        b: [
          :c => 2
        ]
      }
    RUBY
  end

  it 'does not register an offense when using `deep_symbolize_keys` with nested array and non convertible keys' do
    expect_no_offenses(<<~RUBY)
      {
        'a' => 1,
        b: [
          { foo => 2 }
        ]
      }.deep_symbolize_keys
    RUBY
  end

  it 'does not register an offense when using `deep_symbolize_keys` with integer keys' do
    expect_no_offenses(<<~RUBY)
      {
        'a' => 1,
        b: {
          2 => 3
        }
      }.deep_symbolize_keys
    RUBY
  end

  it 'does not register an offense when using `deep_symbolize_keys` with nested array having' \
     'a hash with non literal value' do
    expect_no_offenses(<<~RUBY)
      { a: [{ foo: foo }]  }.deep_symbolize_keys
    RUBY
  end

  it 'does not register an offense when using `deep_symbolize_keys` with non hash literal receiver' do
    expect_no_offenses(<<~RUBY)
      options.deep_symbolize_keys
    RUBY
  end

  it 'does not register an offense when using `deep_symbolize_keys` with non literal values' do
    expect_no_offenses(<<~RUBY)
      { 'a' => 1, b: foo }.deep_symbolize_keys
    RUBY
  end

  it 'registers an offense and corrects when using `deep_stringify_keys` with only string keys' do
    expect_offense(<<~RUBY)
      {
        'a' => 1,
        'b' => {
          'c' => 1
        }
      }.deep_stringify_keys
        ^^^^^^^^^^^^^^^^^^^ Redundant hash keys conversion, all the keys have the required type.
    RUBY

    expect_correction(<<~RUBY)
      {
        'a' => 1,
        'b' => {
          'c' => 1
        }
      }
    RUBY
  end

  it 'registers an offense and corrects when using `deep_stringify_keys` with only symbol and string keys' do
    expect_offense(<<~RUBY)
      {
        'a' => 1,
        b: {
          c: 1
        }
      }.deep_stringify_keys
        ^^^^^^^^^^^^^^^^^^^ Convert hash keys explicitly to the required type.
    RUBY

    expect_correction(<<~RUBY)
      {
        'a' => 1,
        'b'=> {
          'c'=> 1
        }
      }
    RUBY
  end

  it 'does not register an offense when using `deep_stringify_keys` with integer keys' do
    expect_no_offenses(<<~RUBY)
      {
        'a' => 1,
        b: {
          2 => 3
        }
      }.deep_stringify_keys
    RUBY
  end

  it 'does not register an offense when using `deep_stringify_keys` with non hash literal receiver' do
    expect_no_offenses(<<~RUBY)
      options.deep_stringify_keys
    RUBY
  end

  it 'registers an offense and autocorrects when using `symbolize_keys` with empty hash literal' do
    expect_offense(<<~RUBY)
      {}.symbolize_keys
         ^^^^^^^^^^^^^^ Redundant hash keys conversion, all the keys have the required type.
    RUBY

    expect_correction(<<~RUBY)
      {}
    RUBY
  end

  it 'does not register an offense when using `symbolize_keys` with non alphanumeric keys' do
    expect_no_offenses(<<~RUBY)
      { 'hello world' => 1 }.symbolize_keys
    RUBY
  end

  context 'Ruby >= 3.1', :ruby31 do
    it 'does not register an offense when using hash value omission' do
      expect_no_offenses(<<~RUBY)
        { a:, b: 2 }.stringify_keys
      RUBY
    end
  end
end
