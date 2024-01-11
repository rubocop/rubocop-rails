# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EnvironmentVariableAccess, :config do
  context 'when not allowing reads' do
    it 'registers an offense when indexing into `ENV`' do
      expect_offense(<<~RUBY)
        ENV["foo"]
        ^^^ Do not read from `ENV` directly post initialization.
      RUBY
    end

    it 'registers an offense when calling methods on `ENV`' do
      expect_offense(<<~RUBY)
        ENV.fetch("FOO")
        ^^^ Do not read from `ENV` directly post initialization.
      RUBY
    end

    it 'registers an offense when calling methods on dereferenced `ENV`' do
      expect_offense(<<~RUBY)
        ::ENV.fetch("FOO")
        ^^^^^ Do not read from `ENV` directly post initialization.
      RUBY
    end

    it 'does not register an offense on namespaced `ENV` access' do
      expect_no_offenses(<<~RUBY)
        Foo::ENV.fetch("BAR")
      RUBY
    end

    it 'registers an offense when reading from an `ENV` key in the config/initializers folder' do
      file_path = 'config/initializers/foo.rb'

      expect_offense(<<~RUBY, file_path)
        ACCESS_TOKEN = ENV["ACCESS_TOKEN"]
                       ^^^ Do not read from `ENV` directly post initialization.
      RUBY
    end

    it 'does not register an offense when reading from an `ENV` key in the config folder' do
      file_path = '/config/foo.rb'

      expect_no_offenses(<<~RUBY, file_path)
        ACCESS_TOKEN = ENV["ACCESS_TOKEN"]
      RUBY
    end
  end

  context 'when allowing reads' do
    let(:cop_config) do
      { 'AllowReads' => true }
    end

    it 'does not register an offense when indexing into `ENV`' do
      expect_no_offenses(<<~RUBY)
        ENV["foo"]
      RUBY
    end

    it 'does not register an offense when calling methods on `ENV`' do
      expect_no_offenses(<<~RUBY)
        ENV.fetch("FOO")
      RUBY
    end

    it 'does not register an offense when calling methods on dereferenced `ENV`' do
      expect_no_offenses(<<~RUBY)
        ::ENV.fetch("FOO")
      RUBY
    end
  end

  context 'when not allowing writes' do
    it 'registers an offense when writing to an `ENV` key' do
      expect_offense(<<~RUBY)
        ENV["foo"] = "bar"
        ^^^ Do not write to `ENV` directly post initialization.
      RUBY
    end

    it 'registers an offense when writing to a dereferenced `ENV` key' do
      expect_offense(<<~RUBY)
        ::ENV["foo"] = "bar"
        ^^^^^ Do not write to `ENV` directly post initialization.
      RUBY
    end
  end

  context 'when allowing writes' do
    let(:cop_config) do
      { 'AllowWrites' => true }
    end

    it 'does not register an offense when writing to an `ENV` key' do
      expect_no_offenses(<<~RUBY)
        ENV["foo"] = "bar"
      RUBY
    end
  end
end
