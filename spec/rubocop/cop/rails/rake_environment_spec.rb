# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RakeEnvironment, :config do
  it 'registers an offense to task without :environment' do
    expect_offense(<<~RUBY)
      task :foo do
      ^^^^^^^^^ Include `:environment` task as a dependency for all Rake tasks.
      end
    RUBY

    expect_correction(<<~RUBY)
      task foo: :environment do
      end
    RUBY
  end

  it 'registers an offense for string task name' do
    expect_offense(<<~RUBY)
      task 'bar' do
      ^^^^^^^^^^ Include `:environment` task as a dependency for all Rake tasks.
      end
    RUBY

    expect_correction(<<~RUBY)
      task 'bar' => :environment do
      end
    RUBY
  end

  it 'registers an offense for namespaced task name' do
    expect_offense(<<~RUBY)
      task 'foo:bar:baz' do
      ^^^^^^^^^^^^^^^^^^ Include `:environment` task as a dependency for all Rake tasks.
      end
    RUBY

    expect_correction(<<~RUBY)
      task 'foo:bar:baz' => :environment do
      end
    RUBY
  end

  it 'registers an offense for a task with arguments' do
    expect_offense(<<~RUBY)
      task :foo, [:arg] do
      ^^^^^^^^^^^^^^^^^ Include `:environment` task as a dependency for all Rake tasks.
      end
    RUBY

    expect_correction(<<~RUBY)
      task :foo, [:arg] => :environment do
      end
    RUBY
  end

  it 'does not register an offense to task with :environment but it has other dependency before it' do
    expect_no_offenses(<<~RUBY)
      task foo: [:bar, `:environment`] do
      end
    RUBY
  end

  it 'does not register an offense to task with an dependency' do
    expect_no_offenses(<<~RUBY)
      task foo: :bar do
      end
    RUBY
  end

  it 'does not register an offense to task with dependencies' do
    expect_no_offenses(<<~RUBY)
      task foo: [:foo, :bar] do
      end
    RUBY
  end

  it 'does not register an offense to task with a dependency as an array literal element method call' do
    expect_no_offenses(<<~RUBY)
      task foo: [:bar, dep]
    RUBY
  end

  it 'does not register an offense to task with :environment' do
    expect_no_offenses(<<~RUBY)
      task foo: `:environment` do
      end
    RUBY
  end

  it 'does not register an offense to task with :environment and other dependencies' do
    expect_no_offenses(<<~RUBY)
      task foo: [`:environment`, :bar] do
      end
    RUBY
  end

  it 'does not register an offense to task with :environment and an argument' do
    expect_no_offenses(<<~RUBY)
      task :foo, [:arg] => `:environment` do
      end
    RUBY
  end

  it 'does not register an offense to task with a dependency as a method call' do
    expect_no_offenses(<<~RUBY)
      task foo: dep
    RUBY
  end

  it 'does not register an offense to task with dependencies as a method call' do
    expect_no_offenses(<<~RUBY)
      task foo: [dep, :bar]
    RUBY
  end

  it 'does not register an offense to the default task' do
    expect_no_offenses(<<~RUBY)
      task default: :spec
    RUBY
  end

  it 'does not register an offense to task with no block' do
    expect_no_offenses(<<~RUBY)
      task(:foo).do_something
    RUBY
  end

  it 'does not register an offense to task with string name and arguments' do
    expect_no_offenses(<<~RUBY)
      task 'foo' => [dep, :bar]
    RUBY
  end
end
