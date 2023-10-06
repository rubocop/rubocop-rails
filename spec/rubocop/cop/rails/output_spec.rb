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

  it 'registers an offense for methods without arguments' do
    expect_offense(<<~RUBY)
      print
      ^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
      pp
      ^^ Do not write to stdout. Use Rails's logger if you want to log.
      puts
      ^^^^ Do not write to stdout. Use Rails's logger if you want to log.
      $stdout.write
      ^^^^^^^^^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
      STDERR.write
      ^^^^^^^^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
    RUBY
  end

  it 'does not register an offense when a method is called to a local variable with the same name as a print method' do
    expect_no_offenses(<<~RUBY)
      p.do_something
    RUBY
  end

  it 'does not register an offense when the `p` method is called with block argument' do
    expect_no_offenses(<<~RUBY)
      # phlex-rails gem.
      div do
        p { 'Some text' }
      end
    RUBY
  end

  it 'does not register an offense when io method is called with block argument' do
    expect_no_offenses(<<~RUBY)
      obj.write { do_somethig }
    RUBY
  end

  it 'does not register an offense when io method is called with numbered block argument' do
    expect_no_offenses(<<~RUBY)
      obj.write { do_something(_1) }
    RUBY
  end

  it 'does not register an offense when a method is ' \
     'safe navigation called to a local variable with the same name as a print method' do
    expect_no_offenses(<<~RUBY)
      p&.do_something
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
