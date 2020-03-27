# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::BeforeDestroy do
  subject(:cop) { described_class.new }

  it 'registers an offense when not specifying any options' do
    expect_offense(<<~RUBY)
      before_destroy :foo
      ^^^^^^^^^^^^^^ Specify a `:prepend` option.
    RUBY
  end

  it 'registers an offense when missing `prepend: true`' do
    expect_offense(<<~RUBY)
      before_destroy :foo, if: :bar?
      ^^^^^^^^^^^^^^ Specify a `:prepend` option.
    RUBY
  end

  it 'registers no offense when setting `prepend: true`' do
    expect_no_offenses('before_destroy :foo, prepend: true')
  end
end
