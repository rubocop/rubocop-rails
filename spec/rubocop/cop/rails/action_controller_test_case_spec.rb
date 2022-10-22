# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActionControllerTestCase, :config do
  context 'Rails 4.2', :rails42 do
    it 'does not add offense when extending `ActionController::TestCase`' do
      expect_no_offenses(<<~RUBY)
        class MyControllerTest < ActionController::TestCase
        end
      RUBY
    end
  end

  it 'adds offense when extending `ActionController::TestCase`' do
    expect_offense(<<~RUBY)
      class MyControllerTest < ActionController::TestCase
                               ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActionDispatch::IntegrationTest` instead.
      end
    RUBY

    expect_correction(<<~RUBY)
      class MyControllerTest < ActionDispatch::IntegrationTest
      end
    RUBY
  end

  it 'adds offense when extending `::ActionController::TestCase`' do
    expect_offense(<<~RUBY)
      class MyControllerTest < ::ActionController::TestCase
                               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActionDispatch::IntegrationTest` instead.
      end
    RUBY

    expect_correction(<<~RUBY)
      class MyControllerTest < ActionDispatch::IntegrationTest
      end
    RUBY
  end

  it 'adds offense when defining `::MyControllerTest`' do
    expect_offense(<<~RUBY)
      class ::MyControllerTest < ActionController::TestCase
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActionDispatch::IntegrationTest` instead.
      end
    RUBY

    expect_correction(<<~RUBY)
      class ::MyControllerTest < ActionDispatch::IntegrationTest
      end
    RUBY
  end

  it 'adds offense when extending `ActionController::TestCase` and having a method definition' do
    expect_offense(<<~RUBY)
      class MyControllerTest < ActionController::TestCase
                               ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActionDispatch::IntegrationTest` instead.
        def test_foo
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class MyControllerTest < ActionDispatch::IntegrationTest
        def test_foo
        end
      end
    RUBY
  end

  it 'adds offense when extending `ActionController::TestCase` with a namespace' do
    expect_offense(<<~RUBY)
      class Foo::Bar::MyControllerTest < ActionController::TestCase
                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActionDispatch::IntegrationTest` instead.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo::Bar::MyControllerTest < ActionDispatch::IntegrationTest
      end
    RUBY
  end

  it 'does not add offense when extending `ActionDispatch::IntegrationTest`' do
    expect_no_offenses(<<~RUBY)
      class MyControllerTest < ActionDispatch::IntegrationTest
      end
    RUBY
  end

  it 'does not add offense when extending custom superclass' do
    expect_no_offenses(<<~RUBY)
      class MyControllerTest < SuperControllerTest
      end
    RUBY
  end
end
