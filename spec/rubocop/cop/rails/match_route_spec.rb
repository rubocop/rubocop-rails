# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::MatchRoute, :config do
  it 'registers an offense and corrects when using `match` only with path' do
    expect_offense(<<~RUBY)
      routes.draw do
        match ':controller/:action/:id'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `get` instead of `match` to define a route.
      end
    RUBY

    expect_correction(<<~RUBY)
      routes.draw do
        get ':controller/:action/:id'
      end
    RUBY
  end

  it 'registers an offense and corrects when using `match` with single :via' do
    expect_offense(<<~RUBY)
      routes.draw do
        match 'photos/:id', to: 'photos#show', via: :get
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `get` instead of `match` to define a route.
      end
    RUBY

    expect_correction(<<~RUBY)
      routes.draw do
        get 'photos/:id', to: 'photos#show'
      end
    RUBY
  end

  it 'registers an offense and corrects when using `match` with one item in :via array' do
    expect_offense(<<~RUBY)
      routes.draw do
        match 'photos/:id', to: 'photos#show', via: [:get]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `get` instead of `match` to define a route.
      end
    RUBY

    expect_correction(<<~RUBY)
      routes.draw do
        get 'photos/:id', to: 'photos#show'
      end
    RUBY
  end

  it 'registers an offense and corrects when using `match` with hash shorthand' do
    expect_offense(<<~RUBY)
      routes.draw do
        match 'photos/:id' => 'photos#show', via: :get
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `get` instead of `match` to define a route.
      end
    RUBY

    expect_correction(<<~RUBY)
      routes.draw do
        get 'photos/:id' => 'photos#show'
      end
    RUBY
  end

  it 'registers an offense when using match with string interpolation' do
    expect_offense(<<~'RUBY')
      routes.draw do
        match "#{resource}/:action/:id", via: [:put]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `put` instead of `match` to define a route.
      end
    RUBY

    expect_correction(<<~'RUBY')
      routes.draw do
        put "#{resource}/:action/:id"
      end
    RUBY
  end

  it 'does not register an offense when not within routes' do
    expect_no_offenses(<<~RUBY)
      match 'photos/:id', to: 'photos#show', via: :get
    RUBY
  end

  it 'does not register an offense when using `match` with `via: :all`' do
    expect_no_offenses(<<~RUBY)
      routes.draw do
        match 'photos/:id', to: 'photos#show', via: :all
      end
    RUBY
  end

  it 'does not register an offense when using `match` with multiple verbs in :via array' do
    expect_no_offenses(<<~RUBY)
      routes.draw do
        match 'photos/:id', to: 'photos#update', via: [:put, :patch]
      end
    RUBY
  end

  it 'does not register an offense when using `get`' do
    expect_no_offenses(<<~RUBY)
      routes.draw do
        get 'photos/:id', to: 'photos#show'
      end
    RUBY
  end

  it 'does not register an offense when via is a variable' do
    expect_no_offenses(<<~RUBY)
      routes.draw do
        match ':controller/:action/:id', via: method
      end
    RUBY
  end

  context 'Rails >= 8.2', :rails82 do
    it 'registers an offense and corrects when using `match` with `via: :query`' do
      expect_offense(<<~RUBY)
        routes.draw do
          match 'search', to: 'search#index', via: :query
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `query` instead of `match` to define a route.
        end
      RUBY

      expect_correction(<<~RUBY)
        routes.draw do
          query 'search', to: 'search#index'
        end
      RUBY
    end
  end

  context 'Rails <= 8.1', :rails81 do
    it 'does not register an offense when using `match` with `via: :query`' do
      expect_no_offenses(<<~RUBY)
        routes.draw do
          match 'search', to: 'search#index', via: :query
        end
      RUBY
    end
  end
end
