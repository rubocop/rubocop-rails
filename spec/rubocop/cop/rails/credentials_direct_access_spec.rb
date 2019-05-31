# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::CredentialsDirectAccess do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'secrets' do
    it 'registers an offense when not using fetch' do
      expect_offense(<<~RUBY)
        Rails.application.secrets.foo
                                  ^^^ Prefer fetch over direct access.
        Rails.application.secrets.bar
                                  ^^^ Prefer fetch over direct access.
      RUBY
    end

    it 'does not register an offense with fetch' do
      expect_no_offenses(<<~RUBY)
        Rails.application.secrets.fetch(:foo)
      RUBY
    end

    it 'does not register an offense with fetch with default value' do
      expect_no_offenses(<<~RUBY)
        Rails.application.secrets.fetch(:name, "Joe")
      RUBY
    end

    it 'autocorrects to fetch' do
      new_source = autocorrect_source(<<~RUBY)
        Rails.application.secrets.foo
      RUBY

      expect(new_source).to eq(<<~RUBY)
        Rails.application.secrets.fetch(:foo)
      RUBY
    end
  end

  context 'credentials' do
    it 'registers an offense when not using fetch' do
      expect_offense(<<~RUBY)
        Rails.application.credentials.foo
                                      ^^^ Prefer fetch over direct access.
        Rails.application.credentials.bar
                                      ^^^ Prefer fetch over direct access.
      RUBY
    end

    it 'does not register an offense with fetch' do
      expect_no_offenses(<<~RUBY)
        Rails.application.credentials.fetch(:foo)
      RUBY
    end

    it 'does not register an offense with fetch with default value' do
      expect_no_offenses(<<~RUBY)
        Rails.application.credentials.fetch(:age, 20)
      RUBY
    end

    it 'autocorrects to fetch' do
      new_source = autocorrect_source(<<~RUBY)
        Rails.application.credentials.foo
      RUBY

      expect(new_source).to eq(<<~RUBY)
        Rails.application.credentials.fetch(:foo)
      RUBY
    end
  end
end
