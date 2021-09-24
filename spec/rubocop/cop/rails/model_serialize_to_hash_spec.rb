# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ModelSerializeToHash, :config do
  it 'registers an offense for serializing parameters to Hash' do
    expect_offense(<<~RUBY)
      serialize :params, Hash
      ^^^^^^^^^^^^^^^^^^^^^^^ Prefer saving parameters to JSON or manual, if possible.
    RUBY
  end

  it 'does not register an offense for serializing parameters to JSON' do
    expect_no_offenses(<<~RUBY)
      serialize :params, JSON
    RUBY
  end
end
