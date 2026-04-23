# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::HttpPositionalArguments, :config do
  context 'Rails 4.2', :rails42 do
    it 'does not register an offense for get method' do
      expect_no_offenses('get :create, user_id: @user.id')
    end

    it 'does not register an offense for post method' do
      expect_no_offenses('post :create, user_id: @user.id')
    end

    it 'does not register an offense for patch method' do
      expect_no_offenses('patch :update, user_id: @user.id')
    end

    it 'does not register an offense for put method' do
      expect_no_offenses('put :update, user_id: @user.id')
    end

    it 'does not register an offense for delete method' do
      expect_no_offenses('delete :destroy, id: @user.id')
    end

    it 'does not register an offense for head method' do
      expect_no_offenses('head :destroy, id: @user.id')
    end

    it 'does not register an offense for process method' do
      expect_no_offenses(<<~RUBY)
        process :new, method: :get, params: { user_id: @user.id }
      RUBY
    end

    [
      'params: { user_id: @user.id }',
      'xhr: true',
      'session: { foo: \'bar\' }',
      'format: :json'
    ].each do |keyword_args|
      describe "when using keyword args #{keyword_args}" do
        let(:source) do
          "get :new, #{keyword_args}"
        end

        it 'does not register an offense' do
          expect_no_offenses(source)
        end
      end
    end

    describe '.get' do
      it 'does not register an offense' do
        expect_no_offenses('get :new, user_id: @user.id')
      end

      describe 'no params' do
        it 'does not register an offense' do
          expect_no_offenses('get :new')
        end
      end
    end

    describe '.patch' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          patch :update,
                id: @user.id,
                ac: {
                  article_id: @article1.id,
                  profile_id: @profile1.id,
                  content: 'Some Text'
                }
        RUBY
      end
    end

    describe '.post' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          post :create,
               id: @user.id,
               ac: {
                 article_id: @article1.id,
                 profile_id: @profile1.id,
                 content: 'Some Text'
               }
        RUBY
      end
    end

    %w[get post patch put head delete].each do |keyword|
      it 'does not register an offense when keyword is used in a chained method call' do
        expect_no_offenses("@user.#{keyword}.id = ''")
      end
    end
  end

  context 'Rails 5.0 and above', :rails50 do
    it 'registers an offense for get method' do
      expect_offense(<<~RUBY)
        get :create, user_id: @user.id
                     ^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `get`.
      RUBY

      expect_correction(<<~RUBY)
        get :create, params: { user_id: @user.id }
      RUBY
    end

    it 'does not register an offense for get method with `:to` option' do
      expect_no_offenses(<<~RUBY)
        get '/test', to: 'admin/admin#test'
      RUBY
    end

    it 'registers an offense for post method' do
      expect_offense(<<~RUBY)
        post :create, user_id: @user.id
                      ^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
      RUBY

      expect_correction(<<~RUBY)
        post :create, params: { user_id: @user.id }
      RUBY
    end

    it 'registers an offense for patch method' do
      expect_offense(<<~RUBY)
        patch :update, user_id: @user.id
                       ^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `patch`.
      RUBY

      expect_correction(<<~RUBY)
        patch :update, params: { user_id: @user.id }
      RUBY
    end

    it 'registers an offense for put method' do
      expect_offense(<<~RUBY)
        put :create, user_id: @user.id
                     ^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `put`.
      RUBY

      expect_correction(<<~RUBY)
        put :create, params: { user_id: @user.id }
      RUBY
    end

    it 'registers an offense for delete method' do
      expect_offense(<<~RUBY)
        delete :create, user_id: @user.id
                        ^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `delete`.
      RUBY

      expect_correction(<<~RUBY)
        delete :create, params: { user_id: @user.id }
      RUBY
    end

    it 'registers an offense for head method' do
      expect_offense(<<~RUBY)
        head :create, user_id: @user.id
                      ^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `head`.
      RUBY

      expect_correction(<<~RUBY)
        head :create, params: { user_id: @user.id }
      RUBY
    end

    it 'accepts non HTTP methods' do
      expect_no_offenses('puts :create, user_id: @user.id')
    end

    describe 'when using process' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          process :new, method: :get, params: { user_id: @user.id }
        RUBY
      end
    end

    [
      'method: :get',
      'params: { user_id: @user.id }',
      'xhr: true',
      'session: { foo: \'bar\' }',
      'format: :json',
      'headers: {}',
      'body: "foo"',
      'flash: {}',
      'as: :json',
      'env: "test"'
    ].each do |keyword_args|
      describe "when using keyword args #{keyword_args}" do
        it 'does not register an offense' do
          expect_no_offenses("get :new, #{keyword_args}")
        end
      end
    end

    describe 'when using AllowedKeys option value' do
      let(:cop_config) { { 'AllowedKeys' => %w[user_id foo] } }

      it 'does not register an offense' do
        expect_no_offenses("get :new, user_id: @user.id, foo: 'bar'")
      end
    end

    describe '.get' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          get :new, user_id: @user.id
                    ^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `get`.
        RUBY

        expect_correction(<<~RUBY)
          get :new, params: { user_id: @user.id }
        RUBY
      end

      describe 'no params' do
        it 'does not register an offense' do
          expect_no_offenses('get :new')
        end
      end
    end

    describe '.patch' do
      it 'autocorrects offense' do
        expect_offense(<<~RUBY)
          patch :update,
                id: @user.id,
                ^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `patch`.
                ac: {
                  article_id: @article1.id,
                  profile_id: @profile1.id,
                  content: 'Some Text'
                }
        RUBY

        expect_correction(<<~RUBY)
          patch :update, params: { id: @user.id, ac: {
                  article_id: @article1.id,
                  profile_id: @profile1.id,
                  content: 'Some Text'
                } }
        RUBY
      end
    end

    describe '.post' do
      it 'autocorrects offense' do
        expect_offense(<<~RUBY)
          post :create,
               id: @user.id,
               ^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
               ac: {
                 article_id: @article1.id,
                 profile_id: @profile1.id,
                 content: 'Some Text'
               }
        RUBY

        expect_correction(<<~RUBY)
          post :create, params: { id: @user.id, ac: {
                 article_id: @article1.id,
                 profile_id: @profile1.id,
                 content: 'Some Text'
               } }
        RUBY
      end
    end

    %w[head post get patch put delete].each do |keyword|
      it 'does not register an offense when keyword' do
        expect_no_offenses("@user.#{keyword}.id = ''")
      end
    end

    it 'autocorrects http action when method' do
      expect_offense(<<~RUBY)
        post user_attrs, id: 1
                         ^^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
      RUBY

      expect_correction(<<~RUBY)
        post user_attrs, params: { id: 1 }
      RUBY
    end

    it 'autocorrects http action when symbol' do
      expect_offense(<<~RUBY)
        post :user_attrs, id: 1
                          ^^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
      RUBY

      expect_correction(<<~RUBY)
        post :user_attrs, params: { id: 1 }
      RUBY
    end

    it 'maintains parentheses when autocorrecting' do
      expect_offense(<<~RUBY)
        post(:user_attrs, id: 1)
                          ^^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
      RUBY

      expect_correction(<<~RUBY)
        post(:user_attrs, params: { id: 1 })
      RUBY
    end

    it 'maintains quotes when autocorrecting' do
      expect_offense(<<~RUBY)
        get '/auth/linkedin/callback', id: 1
                                       ^^^^^ Use keyword arguments instead of positional arguments for http call: `get`.
      RUBY

      expect_correction(<<~RUBY)
        get '/auth/linkedin/callback', params: { id: 1 }
      RUBY
    end

    it 'does add session keyword when session is used' do
      expect_offense(<<~RUBY)
        get some_path(profile.id), {}, 'HTTP_REFERER' => p_url(p.id).to_s
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `get`.
      RUBY

      expect_correction(<<~RUBY)
        get some_path(profile.id), session: { 'HTTP_REFERER' => p_url(p.id).to_s }
      RUBY
    end

    it 'does not duplicate brackets when hash is already supplied' do
      expect_offense(<<~RUBY)
        get some_path(profile.id), { user_id: @user.id, profile_id: p.id }, 'HTTP_REFERER' => p_url(p.id).to_s
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `get`.
      RUBY

      expect_correction(<<~RUBY)
        get some_path(profile.id), params: { user_id: @user.id, profile_id: p.id }, session: { 'HTTP_REFERER' => p_url(p.id).to_s }
      RUBY
    end

    it 'autocorrects http action when params is a method call' do
      expect_offense(<<~RUBY)
        post :create, confirmation_data
                      ^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
      RUBY

      expect_correction(<<~RUBY)
        post :create, params: confirmation_data
      RUBY
    end

    it 'autocorrects http action when parameter matches special keyword name' do
      expect_offense(<<~RUBY)
        post :create, id: 7, comment: { body: "hei" }
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
      RUBY

      expect_correction(<<~RUBY)
        post :create, params: { id: 7, comment: { body: "hei" } }
      RUBY
    end

    it 'autocorrects http action when format keyword included but not alone' do
      expect_offense(<<~RUBY)
        post :create, id: 7, format: :rss
                      ^^^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
      RUBY

      expect_correction(<<~RUBY)
        post :create, params: { id: 7, format: :rss }
      RUBY
    end

    it 'autocorrects http action when params is a lvar' do
      expect_offense(<<~RUBY)
        params = { id: 1 }
        post user_attrs, params
                         ^^^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
      RUBY

      expect_correction(<<~RUBY)
        params = { id: 1 }
        post user_attrs, params: params
      RUBY
    end

    it 'autocorrects http action when params and action name are method calls' do
      expect_offense(<<~RUBY)
        post user_attrs, params
                         ^^^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
      RUBY

      expect_correction(<<~RUBY)
        post user_attrs, params: params
      RUBY
    end

    it 'autocorrects http action when params is a method call with chain' do
      expect_offense(<<~RUBY)
        post user_attrs, params.merge(foo: bar)
                         ^^^^^^^^^^^^^^^^^^^^^^ Use keyword arguments instead of positional arguments for http call: `post`.
      RUBY

      expect_correction(<<~RUBY)
        post user_attrs, params: params.merge(foo: bar)
      RUBY
    end

    context 'when given a kwsplat hash' do
      # See https://github.com/rubocop/rubocop-rails/issues/352
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          [{ format: :json }, { format: :html }].each do |args|
            get :nothing, **args
          end
        RUBY
      end
    end

    it 'does not register an offense when defining `get` in `routes` block' do
      expect_no_offenses(<<~RUBY)
        routes do
          get :list, on: :collection
        end
      RUBY
    end

    it 'does not register an offense when defining `get` in `routes.draw` block' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          get :list, on: :collection
        end
      RUBY
    end

    it 'does not register an offese for arguments forwaring' do
      expect_no_offenses(<<~RUBY)
        def perform_request(...)
          get(:list, ...)
        end
      RUBY
    end

    it 'does not register an offese for keyword arguments forwaring' do
      expect_no_offenses(<<~RUBY)
        def perform_request(**options)
          get(:list, **options)
        end
      RUBY
    end

    it 'does not register an offese for anonymous keyword arguments forwaring', :ruby32 do
      expect_no_offenses(<<~RUBY)
        def perform_request(**)
          get(:list, **)
        end
      RUBY
    end

    context 'when using `include Rack::Test::Methods`' do
      it 'does not register an offense for get method' do
        expect_no_offenses(<<~RUBY)
          include Rack::Test::Methods

          get :create, user_id: @user.id
        RUBY
      end
    end

    context 'when using `include ::Rack::Test::Methods`' do
      it 'does not register an offense for get method' do
        expect_no_offenses(<<~RUBY)
          include ::Rack::Test::Methods

          get :create, user_id: @user.id
        RUBY
      end
    end
  end
end
