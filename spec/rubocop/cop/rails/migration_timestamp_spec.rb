# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::MigrationTimestamp, :config do
  it 'registers no offenses if timestamp is valid' do
    expect_no_offenses(<<~RUBY, 'db/migrate/20170101000000_good.rb')
      # ...
    RUBY
  end

  it 'registers an offense if timestamp is impossible' do
    expect_offense(<<~RUBY, 'db/migrate/20002222222222_bad.rb')
      # ...
      ^ Migration file name must start with a valid `YYYYmmddHHMMSS_` timestamp in the past.
    RUBY
  end

  it 'registers an offense if timestamp swaps month and day' do
    expect_offense(<<~RUBY, 'db/migrate/20003112000000_bad.rb')
      # ...
      ^ Migration file name must start with a valid `YYYYmmddHHMMSS_` timestamp in the past.
    RUBY
  end

  it 'registers an offense if timestamp day is wrong' do
    expect_offense(<<~RUBY, 'db/migrate/20000231000000_bad.rb')
      # ...
      ^ Migration file name must start with a valid `YYYYmmddHHMMSS_` timestamp in the past.
    RUBY
  end

  it 'registers an offense if timestamp hours are invalid' do
    expect_offense(<<~RUBY, 'db/migrate/20000101240000_bad.rb')
      # ...
      ^ Migration file name must start with a valid `YYYYmmddHHMMSS_` timestamp in the past.
    RUBY
  end

  it 'registers an offense if timestamp minutes are invalid' do
    expect_offense(<<~RUBY, 'db/migrate/20000101006000_bad.rb')
      # ...
      ^ Migration file name must start with a valid `YYYYmmddHHMMSS_` timestamp in the past.
    RUBY
  end

  it 'registers an offense if timestamp seconds are invalid' do
    expect_offense(<<~RUBY, 'db/migrate/20000101000060_bad.rb')
      # ...
      ^ Migration file name must start with a valid `YYYYmmddHHMMSS_` timestamp in the past.
    RUBY
  end

  it 'registers an offense if timestamp is invalid' do
    expect_offense(<<~RUBY, 'db/migrate/123_bad.rb')
      # ...
      ^ Migration file name must start with a valid `YYYYmmddHHMMSS_` timestamp in the past.
    RUBY
  end

  it 'registers an offense if no timestamp at all' do
    expect_offense(<<~RUBY, 'db/migrate/bad.rb')
      # ...
      ^ Migration file name must start with a valid `YYYYmmddHHMMSS_` timestamp in the past.
    RUBY
  end

  it 'registers an offense if the timestamp is in the future' do
    timestamp = (Time.now.utc + 5).strftime('%Y%m%d%H%M%S')
    expect_offense(<<~RUBY, "db/migrate/#{timestamp}_bad.rb")
      # ...
      ^ Migration file name must start with a valid `YYYYmmddHHMMSS_` timestamp in the past.
    RUBY
  end

  it 'registers no offense if the timestamp is in the past' do
    timestamp = (Time.now.utc - 5).strftime('%Y%m%d%H%M%S')
    expect_no_offenses(<<~RUBY, "db/migrate/#{timestamp}_good.rb")
      # ...
    RUBY
  end
end
