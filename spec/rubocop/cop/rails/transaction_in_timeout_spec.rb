# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TransactionInTimeout, :config do
  it 'registers and offense when a transaction is wrapped in a Timeout block' do
    expect_offense(<<~RUBY)
      Timeout.timeout(10) do
        User.transaction do
        ^^^^^^^^^^^^^^^^ Timeouts around transactions may cause unexpected rollbacks.
          user.save
        end
      end
    RUBY
  end

  it 'registers and offense when a transaction is wrapped in a Timeout block with all parameters' do
    expect_offense(<<~RUBY)
      Timeout.timeout(10, StandardError, "A timeout has occurred") do
        User.transaction do
        ^^^^^^^^^^^^^^^^ Timeouts around transactions may cause unexpected rollbacks.
          user.save
        end
      end
    RUBY
  end

  it 'does not register an offence when a transaction is outside of a Timeout block' do
    expect_no_offenses(<<~RUBY)
      Timeout.timeout(10) do
        a = b + 1
      end
      User.transaction do
        user.save
      end
    RUBY
  end
end
