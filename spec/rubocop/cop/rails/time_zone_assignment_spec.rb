# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TimeZoneAssignment, :config do
  it 'registers an offense for `Time.zone=`' do
    expect_offense(<<~RUBY)
      Time.zone = 'EST'
      ^^^^^^^^^^^^^^^^^ Use `Time.use_zone` with block instead of `Time.zone=`.
    RUBY
  end

  it 'registers an offense for `::Time.zone=`' do
    expect_offense(<<~RUBY)
      ::Time.zone = 'EST'
      ^^^^^^^^^^^^^^^^^^^ Use `Time.use_zone` with block instead of `Time.zone=`.
    RUBY
  end

  it 'accepts `Time.use_zone`' do
    expect_no_offenses(<<~RUBY)
      Time.use_zone('EST') do
        current_est_time = Time.zone.now
      end
    RUBY
  end
end
