# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Exit, :config do
  it 'registers an offense for an exit call with no receiver' do
    expect_offense(<<~RUBY)
      exit
      ^^^^ Do not use `exit` in Rails applications.
    RUBY
  end

  it 'registers an offense for an exit! call with no receiver' do
    expect_offense(<<~RUBY)
      exit!
      ^^^^^ Do not use `exit!` in Rails applications.
    RUBY
  end

  it 'registers an offense for an abort call with no receiver' do
    expect_offense(<<~RUBY)
      abort
      ^^^^^ Do not use `abort` in Rails applications.
    RUBY
  end

  context 'exit calls on objects' do
    it 'does not register an offense for an explicit exit call on an object' do
      expect_no_offenses('Object.new.exit')
    end

    it 'does not register an offense for an explicit exit call with an argument on an object' do
      expect_no_offenses('Object.new.exit(0)')
    end

    it 'does not register an offense for an explicit exit! call on an object' do
      expect_no_offenses('Object.new.exit!(0)')
    end

    it 'does not register an offense for an explicit abort call on an object' do
      expect_no_offenses('Object.new.abort("failed")')
    end
  end

  context 'with arguments' do
    it 'registers an offense for an exit(0) call with no receiver' do
      expect_offense(<<~RUBY)
        exit(0)
        ^^^^ Do not use `exit` in Rails applications.
      RUBY
    end

    it 'ignores exit calls with unexpected number of parameters' do
      expect_no_offenses('exit(1, 2)')
    end

    it 'registers an offense for an abort("message") call with no receiver' do
      expect_offense(<<~RUBY)
        abort("message")
        ^^^^^ Do not use `abort` in Rails applications.
      RUBY
    end

    it 'ignores abort calls with unexpected number of parameters' do
      expect_no_offenses('abort("message", "another message")')
    end
  end

  context 'explicit calls' do
    it 'does register an offense for explicit Kernel.exit calls' do
      expect_offense(<<~RUBY)
        Kernel.exit
               ^^^^ Do not use `exit` in Rails applications.
      RUBY
    end

    it 'does register an offense for explicit Process.exit calls' do
      expect_offense(<<~RUBY)
        Process.exit
                ^^^^ Do not use `exit` in Rails applications.
      RUBY
    end

    it 'does register an offense for explicit Kernel.abort calls' do
      expect_offense(<<~RUBY)
        Kernel.abort
               ^^^^^ Do not use `abort` in Rails applications.
      RUBY
    end

    it 'does register an offense for explicit Process.abort calls' do
      expect_offense(<<~RUBY)
        Process.abort
                ^^^^^ Do not use `abort` in Rails applications.
      RUBY
    end
  end
end
