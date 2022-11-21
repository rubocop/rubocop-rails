# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActiveRecordBulkPersistence, :config do
  it 'does not register an offense when there is no save' do
    expect_no_offenses('User.all.each { |u| u.something }')
  end

  it 'registers an offense when there is a save in a loop' do
    expect_offense(<<~RUBY)
      User.all.each { |u| u.save }
                            ^^^^ For bulk operations, use `insert_all` or `upsert_all` instead of repeated calls to `save`.
    RUBY
  end

  it 'registers an offense when there is a save in a multi line block' do
    expect_offense(<<~RUBY)
      User.all.each do |u|
        foo = u.save
                ^^^^ For bulk operations, use `insert_all` or `upsert_all` instead of repeated calls to `save`.
      end
    RUBY
  end

  it 'does not register an offense on non-iterative block' do
    expect_no_offenses(<<~RUBY)
      User.with_lock do |u|
        foo = u.save
      end
    RUBY
  end

  it 'registers offense on each_with_index and save_without_updating_search_document' do
    expect_offense(<<~RUBY)
      vs.each_with_index do |v, _i|
        v.save!
          ^^^^^ For bulk operations, use `insert_all` or `upsert_all` instead of repeated calls to `save!`.
      end
    RUBY
  end
end
