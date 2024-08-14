# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::HashKeyValueRoute, :config do
  context 'when using hash key-value route' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        get '/foos' => 'foos#index'
            ^^^^^^^^^^^^^^^^^^^^^^^ Avoid Hash key-value routing.
      RUBY

      expect_correction(<<~RUBY)
        get '/foos', to: 'foos#index'
      RUBY
    end
  end

  context 'with other options' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        get '/foos' => 'foos#index', as: 'foos'
            ^^^^^^^^^^^^^^^^^^^^^^^ Avoid Hash key-value routing.
      RUBY

      expect_correction(<<~RUBY)
        get '/foos', to: 'foos#index', as: 'foos'
      RUBY
    end
  end

  context 'with `mount`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        mount MyApp => '/my_app'
              ^^^^^^^^^^^^^^^^^^ Avoid Hash key-value routing.
      RUBY

      expect_correction(<<~RUBY)
        mount MyApp, at: '/my_app'
      RUBY
    end
  end

  context 'without hash key-value route' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        get '/foos', to: 'foos#index'
      RUBY
    end
  end
end
