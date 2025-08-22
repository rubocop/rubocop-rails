# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ConstantInRoutes, :config do
  context 'when in config/routes.rb file' do
    let(:source) { 'config/routes.rb' }

    it 'registers an offense when defining constants in routes' do
      expect_offense(<<~RUBY, source)
        API_VERSION = 'v1'
        ^^^^^^^^^^^^^^^^^^ Do not define constants in config/routes.rb. Use a local variable or move this constant somewhere else.
        Rails.application.routes.draw do
          BASE_PATH = '/api'
          ^^^^^^^^^^^^^^^^^^ Do not define constants in config/routes.rb. Use a local variable or move this constant somewhere else.
          get "\#{BASE_PATH}\#{API_VERSION}/users", to: 'users#index'
        end
      RUBY
    end

    it 'registers an offense when defining nested constants' do
      expect_offense(<<~RUBY, source)
        Api::VERSION = 'v1'
        ^^^^^^^^^^^^^^^^^^^ Do not define constants in config/routes.rb. Use a local variable or move this constant somewhere else.
        Rails.application.routes.draw do
          get "/users", to: 'users#index'
        end
      RUBY
    end

    it 'registers an offense when defining constants in opened classes' do
      expect_offense(<<~RUBY, source)
        class Api
          VERSION = 'v1'
          ^^^^^^^^^^^^^^ Do not define constants in config/routes.rb. Use a local variable or move this constant somewhere else.
        end
        Rails.application.routes.draw do
          get "/users", to: 'users#index'
        end
      RUBY
    end
  end
end
