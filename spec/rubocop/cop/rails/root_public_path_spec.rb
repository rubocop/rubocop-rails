# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RootPublicPath, :config do
  it "does not register an offense when using `Rails.root.join('public_stuff')`" do
    expect_no_offenses(<<~RUBY)
      Rails.root.join('public_stuff')
    RUBY
  end

  it "registers an offense when using `::Rails.root.join('public')`" do
    expect_offense(<<~RUBY)
      ::Rails.root.join('public')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.public_path`.
    RUBY

    expect_correction(<<~RUBY)
      ::Rails.public_path
    RUBY
  end

  it "registers an offense when using `Rails.root.join('public')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('public')
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.public_path`.
    RUBY

    expect_correction(<<~RUBY)
      Rails.public_path
    RUBY
  end

  it "registers an offense when using `Rails.root.join('public/file.pdf')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('public/file.pdf')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.public_path`.
    RUBY

    expect_correction(<<~RUBY)
      Rails.public_path.join('file.pdf')
    RUBY
  end

  it "registers an offense when using `Rails.root.join('public', 'file.pdf')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('public', 'file.pdf')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.public_path`.
    RUBY

    expect_correction(<<~RUBY)
      Rails.public_path.join('file.pdf')
    RUBY
  end

  it "registers an offense when using `Rails.root.join('public/path/file.pdf')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('public/path/file.pdf')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.public_path`.
    RUBY

    expect_correction(<<~RUBY)
      Rails.public_path.join('path/file.pdf')
    RUBY
  end

  it "registers an offense when using `Rails.root.join('public/path', 'file.pdf')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('public/path', 'file.pdf')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.public_path`.
    RUBY

    expect_correction(<<~RUBY)
      Rails.public_path.join('path', 'file.pdf')
    RUBY
  end

  it "registers an offense when using `Rails.root.join('public', 'path/file.pdf')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('public', 'path/file.pdf')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.public_path`.
    RUBY

    expect_correction(<<~RUBY)
      Rails.public_path.join('path/file.pdf')
    RUBY
  end

  it "registers an offense when using `Rails.root.join('public', path, 'file.pdf')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('public', path, 'file.pdf')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.public_path`.
    RUBY

    expect_correction(<<~RUBY)
      Rails.public_path.join(path, 'file.pdf')
    RUBY
  end
end
