# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DotSeparatedKeys, :config do
  it 'registers an offense and corrects when translating keys with convertible scopes' do
    expect_offense(<<~RUBY)
      I18n.t :key, scope: [:one, :two]
                   ^^^^^^^^^^^^^^^^^^^ Use the dot-separated keys instead of specifying the `:scope` option.
      I18n.translate :key, scope: [:one, :two]
                           ^^^^^^^^^^^^^^^^^^^ Use the dot-separated keys instead of specifying the `:scope` option.
      t :key, scope: [:one, :two]
              ^^^^^^^^^^^^^^^^^^^ Use the dot-separated keys instead of specifying the `:scope` option.
      translate :key, scope: [:one, :two]
                      ^^^^^^^^^^^^^^^^^^^ Use the dot-separated keys instead of specifying the `:scope` option.
      t :key, scope: [:one, :two], default: 'Not here'
              ^^^^^^^^^^^^^^^^^^^ Use the dot-separated keys instead of specifying the `:scope` option.
      I18n.t :key, scope: ['one', :two]
                   ^^^^^^^^^^^^^^^^^^^^ Use the dot-separated keys instead of specifying the `:scope` option.
      I18n.t 'key', scope: [:one, :two]
                    ^^^^^^^^^^^^^^^^^^^ Use the dot-separated keys instead of specifying the `:scope` option.
      I18n.t :key, scope: :one
                   ^^^^^^^^^^^ Use the dot-separated keys instead of specifying the `:scope` option.
      I18n.t '.key', scope: :one
                     ^^^^^^^^^^^ Use the dot-separated keys instead of specifying the `:scope` option.
    RUBY

    expect_correction(<<~RUBY)
      I18n.t 'one.two.key'
      I18n.translate 'one.two.key'
      t 'one.two.key'
      translate 'one.two.key'
      t 'one.two.key', default: 'Not here'
      I18n.t 'one.two.key'
      I18n.t 'one.two.key'
      I18n.t 'one.key'
      I18n.t 'one.key'
    RUBY
  end

  it 'registers an offense and corrects when translating keys with convertible scopes are used with `::I18n`' do
    expect_offense(<<~RUBY)
      ::I18n.t :key, scope: [:one, :two]
                     ^^^^^^^^^^^^^^^^^^^ Use the dot-separated keys instead of specifying the `:scope` option.
    RUBY

    expect_correction(<<~RUBY)
      ::I18n.t 'one.two.key'
    RUBY
  end

  it 'does not register an offense when key is an array' do
    expect_no_offenses(<<~RUBY)
      t [:key1, :key2], scope: :one
    RUBY
  end

  it 'does not register an offense when key is not a basic literal' do
    expect_no_offenses(<<~RUBY)
      t key1, scope: :one
    RUBY
  end

  it 'does not register an offense when `scope` is an array containing non literals' do
    expect_no_offenses(<<~RUBY)
      t :key, scope: [:one, two]
    RUBY
  end

  it 'does not register an offense when `scope` is a string' do
    expect_no_offenses(<<~RUBY)
      t :key, scope: 'one'
    RUBY
  end

  it 'does not register an offense when `scope` is not a literal' do
    expect_no_offenses(<<~RUBY)
      t :key, scope: something
    RUBY
  end

  it 'does not register an offense when there is no `scope`' do
    expect_no_offenses(<<~RUBY)
      t :key
    RUBY
  end
end
