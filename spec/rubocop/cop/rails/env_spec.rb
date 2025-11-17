# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Env, :config do
  it 'registers an offense for `Rails.env.development? || Rails.env.test?`' do
    expect_offense(<<~RUBY)
      Rails.env.development? || Rails.env.test?
                                ^^^^^^^^^^^^^^^ Use Feature Flags or config instead of `Rails.env`.
      ^^^^^^^^^^^^^^^^^^^^^^ Use Feature Flags or config instead of `Rails.env`.
    RUBY
  end

  it 'registers an offense for `Rails.env.production?`' do
    expect_offense(<<~RUBY)
      Rails.env.production?
      ^^^^^^^^^^^^^^^^^^^^^ Use Feature Flags or config instead of `Rails.env`.
    RUBY
  end

  it 'does not register an offense for `Rails.env`' do
    expect_no_offenses(<<~RUBY)
      Rails.env
    RUBY
  end

  it 'does not register an offense when assigning `Rails.env`' do
    expect_no_offenses(<<~RUBY)
      rails_env = Rails.env
    RUBY
  end

  it 'does not register an offense for valid Rails.env methods' do
    expect_no_offenses(<<~RUBY)
      Rails.env.capitalize
      Rails.env.empty?
    RUBY
  end

  it 'does not register an offense for unrelated config' do
    expect_no_offenses(<<~RUBY)
      Rails.environment
    RUBY
  end
end
