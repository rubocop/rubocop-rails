# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Output do
  subject(:cop) { described_class.new }

  it 'registers an offense for methods without a receiver' do
    expect_offense(<<~RUBY)
      p "edmond dantes"
      ^ Do not write to stdout. Use Rails's logger if you want to log.
      puts "sinbad"
      ^^^^ Do not write to stdout. Use Rails's logger if you want to log.
      print "abbe busoni"
      ^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
      pp "monte cristo"
      ^^ Do not write to stdout. Use Rails's logger if you want to log.
      $stdout.write "lord wilmore"
              ^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
      $stderr.syswrite "faria"
              ^^^^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
      STDOUT.write "bertuccio"
             ^^^^^ Do not write to stdout. Use Rails's logger if you want to log.
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
