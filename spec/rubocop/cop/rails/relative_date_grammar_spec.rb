# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RelativeDateGrammar, :config do
  it 'accepts ActiveSupport::Duration as a receiver (ActiveSupport::Duration#since)' do
    expect_no_offenses(<<~RUBY)
      yesterday = 1.day.since(Time.current)
    RUBY
  end

  it 'registers an offense for Date(Time) as a receiver (ActiveSupport::TimeWithZone#ago)' do
    expect_offense(<<~RUBY)
      last_week = Time.current.ago(1.week)
                  ^^^^^^^^^^^^^^^^^^^^^^^^ Use ActiveSupport::Duration#ago as a receiver for relative date like `1.week.ago(Time.current)`.
    RUBY

    expect_correction(<<~RUBY)
      last_week = 1.week.ago(Time.current)
    RUBY
  end

  it 'registers an offense when a receiver is presumably Date(Time)' do
    expect_offense(<<~RUBY)
      expiration_time = purchase.created_at.since(ticket.expires_in.seconds)
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use ActiveSupport::Duration#since as a receiver for relative date like `ticket.expires_in.seconds.since(purchase.created_at)`.
    RUBY

    expect_correction(<<~RUBY)
      expiration_time = ticket.expires_in.seconds.since(purchase.created_at)
    RUBY
  end
end
