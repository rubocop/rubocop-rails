# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RootJoinChain, :config do
  it 'does not register an offense for `Rails.root.join(...)`' do
    expect_no_offenses(<<~RUBY)
      Rails.root.join('db', 'schema.rb')
    RUBY
  end

  it 'registers an offense and corrects for `::Rails.root.join(...).join(...)`' do
    expect_offense(<<~RUBY)
      ::Rails.root.join('db').join('sch' + 'ema.rb')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `::Rails.root.join(...)` instead of chaining `#join` calls.
    RUBY

    expect_correction(<<~RUBY)
      ::Rails.root.join('db', 'sch' + 'ema.rb')
    RUBY
  end

  it 'registers an offense and corrects for `::Rails.root.join(...).join(...).read`' do
    expect_offense(<<~RUBY)
      ::Rails.root.join('db').join('sch' + 'ema.rb').read
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `::Rails.root.join(...)` instead of chaining `#join` calls.
    RUBY

    expect_correction(<<~RUBY)
      ::Rails.root.join('db', 'sch' + 'ema.rb').read
    RUBY
  end

  it 'registers an offense and corrects for `Rails.root.join(...).join(...)`' do
    expect_offense(<<~RUBY)
      Rails.root.join('db').join('sch' + 'ema.rb')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.root.join(...)` instead of chaining `#join` calls.
    RUBY

    expect_correction(<<~RUBY)
      Rails.root.join('db', 'sch' + 'ema.rb')
    RUBY
  end

  it 'registers an offense and corrects for `Rails.root` with any number of joins greater one' do
    expect_offense(<<~RUBY)
      Rails.root.join.join.join('db').join(migrate).join.join("migration.\#{rb}")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.root.join(...)` instead of chaining `#join` calls.
    RUBY

    expect_correction(<<~RUBY)
      Rails.root.join('db', migrate, "migration.\#{rb}")
    RUBY
  end

  it 'does not register an offense for `Rails.public_path.join(...)`' do
    expect_no_offenses(<<~RUBY)
      Rails.public_path.join('path', 'file.pdf')
    RUBY
  end

  it 'registers an offense and corrects for `Rails.public_path.join(...).join(...)`' do
    expect_offense(<<~RUBY)
      Rails.public_path.join('path').join('fi' + 'le.pdf')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.public_path.join(...)` instead of chaining `#join` calls.
    RUBY

    expect_correction(<<~RUBY)
      Rails.public_path.join('path', 'fi' + 'le.pdf')
    RUBY
  end

  it 'registers an offense and corrects for `Rails.public_path` with any number of joins greater one' do
    expect_offense(<<~RUBY)
      Rails.public_path.join.join.join('path').join(to).join.join("file.\#{pdf}")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.public_path.join(...)` instead of chaining `#join` calls.
    RUBY

    expect_correction(<<~RUBY)
      Rails.public_path.join('path', to, "file.\#{pdf}")
    RUBY
  end
end
