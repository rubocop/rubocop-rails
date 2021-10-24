# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DurationArithmetic, :config do
  it 'registers an offense and corrects' do
    expect_offense(<<~RUBY)
      Time.zone.now - 1.minute
      ^^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      Time.current + 2.days
      ^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
      ::Time.current + 1.hour
      ^^^^^^^^^^^^^^^^^^^^^^^ Do not add or subtract duration.
    RUBY

    expect_correction(<<~RUBY)
      1.minute.ago
      2.days.from_now
      1.hour.from_now
    RUBY
  end

  it 'does not register an offense for two duration operands' do
    expect_no_offenses(<<~RUBY)
      3.days - 1.hour
      3.days + 1.hour
    RUBY
  end

  it 'does not register an offense if the left operand is non current time' do
    expect_no_offenses(<<~RUBY)
      5.hours + Time.current # will raise
      Date.yesterday + 3.days
      created_at - 1.minute
    RUBY
  end
end
