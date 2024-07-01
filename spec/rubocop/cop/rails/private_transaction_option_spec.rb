# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::PrivateTransactionOption, :config do
  it 'registers an offense when using `joinable: false`' do
    expect_offense(<<~RUBY)
      ActiveRecord::Base.transaction(requires_new: true, joinable: false)
                                                         ^^^^^^^^^^^^^^^ Do not use `ActiveRecord::Base.transaction(joinable: _)`.
    RUBY
  end

  it 'does not register an offense when using only `requires_new: true`' do
    expect_no_offenses(<<~RUBY)
      ActiveRecord::Base.transaction(requires_new: true)
    RUBY
  end
end
