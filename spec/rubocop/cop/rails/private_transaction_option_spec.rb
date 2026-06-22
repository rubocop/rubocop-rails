# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::PrivateTransactionOption, :config do
  it 'registers an offense when using `ActiveRecord::Base.joinable: false`' do
    expect_offense(<<~RUBY)
      ActiveRecord::Base.transaction(requires_new: true, joinable: false) do
                                                         ^^^^^^^^^^^^^^^ Use a negated `requires_new` option instead of the internal `joinable`.
        # ...
      end
    RUBY
  end

  it 'registers an offense when using `Account.transaction(joinable: false)`' do
    expect_offense(<<~RUBY)
      Account.transaction(requires_new: true, joinable: false) do
                                              ^^^^^^^^^^^^^^^ Use a negated `requires_new` option instead of the internal `joinable`.
        # ...
      end
    RUBY
  end

  it 'does not register an offense when using only `requires_new: true`' do
    expect_no_offenses(<<~RUBY)
      ActiveRecord::Base.transaction(requires_new: true) do
        # ...
      end
    RUBY
  end
end
