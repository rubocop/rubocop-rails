# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Output, :config do
  it 'registers and corrects an offense for using `p` method without a receiver' do
    expect_offense(<<~RUBY)
      p "edmond dantes"
      ^ Do not write to stdout. Use Rails's logger if you want to log.
    RUBY

    expect_correction(<<~RUBY)
      Rails.logger.debug "edmond dantes"
    RUBY
  end

  it 'registers and corrects an offense for using `puts` method without a receiver' do
    expect_offense(<<~RUBY)
      puts "sinbad"
      ^^^^ Do not write to stdout. Use Rails's logger if you want to log.
    RUBY

    expect_correction(<<~RUBY)
      Rails.logger.debug "sinbad"
    RUBY
  end

  it 'registers and corrects an offense for using `print` method without a receiver' do
    expect_offense(<<~RUBY)
      print "abbe busoni"
      ^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
    RUBY

    expect_correction(<<~RUBY)
      Rails.logger.debug "abbe busoni"
    RUBY
  end

  it 'registers and corrects an offense for using `pp` method without a receiver' do
    expect_offense(<<~RUBY)
      pp "monte cristo"
      ^^ Do not write to stdout. Use Rails's logger if you want to log.
    RUBY

    expect_correction(<<~RUBY)
      Rails.logger.debug "monte cristo"
    RUBY
  end

  it 'registers and corrects an offense with `$stdout.write`' do
    expect_offense(<<~RUBY)
      $stdout.write "lord wilmore"
      ^^^^^^^^^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
    RUBY

    expect_correction(<<~RUBY)
      Rails.logger.debug "lord wilmore"
    RUBY
  end

  it 'registers and corrects an offense with `$stderr.syswrite`' do
    expect_offense(<<~RUBY)
      $stderr.syswrite "faria"
      ^^^^^^^^^^^^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
    RUBY

    expect_correction(<<~RUBY)
      Rails.logger.debug "faria"
    RUBY
  end

  it 'registers and corrects an offense with `STDOUT.write`' do
    expect_offense(<<~RUBY)
      STDOUT.write "bertuccio"
      ^^^^^^^^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
    RUBY

    expect_correction(<<~RUBY)
      Rails.logger.debug "bertuccio"
    RUBY
  end

  it 'registers and corrects an offense with `::STDOUT.write`' do
    expect_offense(<<~RUBY)
      ::STDOUT.write "bertuccio"
      ^^^^^^^^^^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
    RUBY

    expect_correction(<<~RUBY)
      Rails.logger.debug "bertuccio"
    RUBY
  end

  it 'registers and corrects an offense with `STDERR.write`' do
    expect_offense(<<~RUBY)
      STDERR.write "bertuccio"
      ^^^^^^^^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
    RUBY

    expect_correction(<<~RUBY)
      Rails.logger.debug "bertuccio"
    RUBY
  end

  it 'registers and corrects an offense with `::STDERR.write`' do
    expect_offense(<<~RUBY)
      ::STDERR.write "bertuccio"
      ^^^^^^^^^^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
    RUBY

    expect_correction(<<~RUBY)
      Rails.logger.debug "bertuccio"
    RUBY
  end

  it 'does not record an offense for methods with a receiver' do
    expect_no_offenses(<<~RUBY)
      obj.print
      something.p
      nothing.pp
    RUBY
  end

  it 'does not record an offense for methods without arguments' do
    expect_no_offenses(<<~RUBY)
      print
      pp
      puts
      $stdout.write
      STDERR.write
    RUBY
  end

  it 'does not record an offense for comments' do
    expect_no_offenses(<<~RUBY)
      # print "test"
      # p
      # $stdout.write
      # STDERR.binwrite
    RUBY
  end
end
