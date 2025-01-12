# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::MultipleRoutePaths, :config do
  it 'registers an offense when using a route with multiple string route paths' do
    expect_offense(<<~RUBY)
      Rails.application.routes.draw do
        get '/users', '/other_path/users', '/another_path/users'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use separate routes instead of combining multiple route paths in a single route.
      end
    RUBY

    expect_correction(<<~RUBY)
      Rails.application.routes.draw do
        get '/users'
        get '/other_path/users'
        get '/another_path/users'
      end
    RUBY
  end

  it 'registers an offense when using a route with multiple route paths with option' do
    expect_offense(<<~RUBY)
      Rails.application.routes.draw do
        get '/users', '/other_path/users', '/another_path/users', to: 'users#index'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use separate routes instead of combining multiple route paths in a single route.
      end
    RUBY

    expect_correction(<<~RUBY)
      Rails.application.routes.draw do
        get '/users', to: 'users#index'
        get '/other_path/users', to: 'users#index'
        get '/another_path/users', to: 'users#index'
      end
    RUBY
  end

  it 'registers an offense when using a route with multiple route paths with splat option' do
    expect_offense(<<~RUBY)
      Rails.application.routes.draw do
        get '/users', '/other_path/users', '/another_path/users', **options
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use separate routes instead of combining multiple route paths in a single route.
      end
    RUBY

    expect_correction(<<~RUBY)
      Rails.application.routes.draw do
        get '/users', **options
        get '/other_path/users', **options
        get '/another_path/users', **options
      end
    RUBY
  end

  it 'registers an offense when using a route with multiple symbol route paths' do
    expect_offense(<<~RUBY)
      Rails.application.routes.draw do
        get :resend, :generate_new_password
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use separate routes instead of combining multiple route paths in a single route.
      end
    RUBY

    expect_correction(<<~RUBY)
      Rails.application.routes.draw do
        get :resend
        get :generate_new_password
      end
    RUBY
  end

  it 'does not register an offense when using single string path method calls' do
    expect_no_offenses(<<~RUBY)
      Rails.application.routes.draw do
        get '/users'
        get '/other_path/users'
        get '/another_path/users'
      end
    RUBY
  end

  it 'does not register an offense when using single string path with option method calls' do
    expect_no_offenses(<<~RUBY)
      Rails.application.routes.draw do
        get '/users', to: 'users#index'
        get '/other_path/users', to: 'users#index'
        get '/another_path/users', to: 'users#index'
      end
    RUBY
  end

  it 'does not register an offense when using single string path with array literal' do
    expect_no_offenses(<<~RUBY)
      Rails.application.routes.draw do
        get '/other_path/users', []
      end
    RUBY
  end

  it 'does not register an offense when using single route path with no arguments' do
    expect_no_offenses(<<~RUBY)
      Rails.application.routes.draw do
        get
      end
    RUBY
  end

  it 'does not register an offense when not within routes' do
    expect_no_offenses(<<~RUBY)
      get '/users', '/other_path/users', '/another_path/users'
    RUBY
  end
end
