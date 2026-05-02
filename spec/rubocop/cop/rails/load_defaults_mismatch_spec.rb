# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::LoadDefaultsMismatch, :config do
  context 'when targeting Rails 8.1', :rails81 do
    it 'does not register an offense when load_defaults matches the target version' do
      expect_no_offenses(<<~RUBY)
        config.load_defaults 8.1
      RUBY
    end

    it 'registers an offense when load_defaults has a different minor version' do
      expect_offense(<<~RUBY)
        config.load_defaults 7.0
                             ^^^ `load_defaults` is set to `7.0` but the target Rails version is `8.1`. Update `load_defaults` to match the Rails version after completing the upgrade.
      RUBY
    end

    it 'registers an offense when load_defaults has a different major version' do
      expect_offense(<<~RUBY)
        config.load_defaults 6.1
                             ^^^ `load_defaults` is set to `6.1` but the target Rails version is `8.1`. Update `load_defaults` to match the Rails version after completing the upgrade.
      RUBY
    end

    it 'registers an offense when load_defaults major version is ahead' do
      expect_offense(<<~RUBY)
        config.load_defaults 8.0
                             ^^^ `load_defaults` is set to `8.0` but the target Rails version is `8.1`. Update `load_defaults` to match the Rails version after completing the upgrade.
      RUBY
    end
  end

  context 'when targeting Rails 8.0', :rails80 do
    it 'does not register an offense when load_defaults matches' do
      expect_no_offenses(<<~RUBY)
        config.load_defaults 8.0
      RUBY
    end

    it 'registers an offense when load_defaults is 7.0' do
      expect_offense(<<~RUBY)
        config.load_defaults 7.0
                             ^^^ `load_defaults` is set to `7.0` but the target Rails version is `8.0`. Update `load_defaults` to match the Rails version after completing the upgrade.
      RUBY
    end
  end

  context 'when load_defaults receives an integer', :rails80 do
    it 'does not register an offense when it matches' do
      expect_no_offenses(<<~RUBY)
        config.load_defaults 8
      RUBY
    end

    it 'registers an offense when it does not match' do
      expect_offense(<<~RUBY)
        config.load_defaults 6
                             ^ `load_defaults` is set to `6.0` but the target Rails version is `8.0`. Update `load_defaults` to match the Rails version after completing the upgrade.
      RUBY
    end
  end
end
