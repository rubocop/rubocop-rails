# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::BeforeDestroy do
  subject(:cop) { described_class.new }

  it 'registers an offense when not specifying any options with method type' do
    expect_offense(<<~RUBY)
      before_destroy :foo
      ^^^^^^^^^^^^^^ Specify a `:prepend` option.
    RUBY
  end

  it 'registers an offense when not specifying any options with block type' do
    expect_offense(<<~RUBY)
      before_destroy do
      ^^^^^^^^^^^^^^ Specify a `:prepend` option.
        # some code
      end
    RUBY
  end

  it 'registers an offense when missing `prepend: true`' do
    expect_offense(<<~RUBY)
      before_destroy :foo, if: :bar?
      ^^^^^^^^^^^^^^ Specify a `:prepend` option.
    RUBY
  end

  it 'registers no offense when setting `prepend: true` with method type' do
    expect_no_offenses(<<~RUBY)
      before_destroy :foo, prepend: true
    RUBY
  end

  it 'registers no offense when setting `prepend: true` with block type' do
    expect_no_offenses(<<~RUBY)
      before_destroy prepend: true do
        # some code
      end
    RUBY
  end

  it 'registers no offense for match in any order' do
    expect_no_offenses(<<~RUBY)
      before_destroy :foo, if: :bar?, prepend: true
    RUBY
  end
end
