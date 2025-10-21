# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ClassDescendants, :config do
  it 'registers an offense when using `descendants`' do
    expect_offense(<<~RUBY)
      User.descendants
      ^^^^^^^^^^^^^^^^ Avoid using `descendants` as it may not include classes that have yet to be autoloaded and is non-deterministic with regards to Garbage Collection.
    RUBY
  end
end
