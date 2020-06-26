# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::NegateInclude do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects when using `!include?`' do
    expect_offense(<<~RUBY)
      !array.include?(2)
      ^^^^^^^^^^^^^^^^^^ Use `.exclude?` and remove the negation part.
    RUBY

    expect_correction(<<~RUBY)
      array.exclude?(2)
    RUBY
  end

  it 'does not register an offense when using `include?` or `exclude?`' do
    expect_no_offenses(<<~RUBY)
      array.include?(2)
      array.exclude?(2)
    RUBY
  end
end
