# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::HttpStatus, :config do
  context 'when EnforcedStyle is `symbolic`' do
    let(:cop_config) { { 'EnforcedStyle' => 'symbolic' } }

    it 'registers an offense and corrects using numeric value' do
      expect_offense(<<~RUBY)
        render :foo, status: 200
                             ^^^ Prefer `:ok` over `200` to define HTTP status code.
        render json: { foo: 'bar' }, status: 404
                                             ^^^ Prefer `:not_found` over `404` to define HTTP status code.
        render status: 404, json: { foo: 'bar' }
                       ^^^ Prefer `:not_found` over `404` to define HTTP status code.
        render plain: 'foo/bar', status: 304
                                         ^^^ Prefer `:not_modified` over `304` to define HTTP status code.
        redirect_to root_url, status: 301
                                      ^^^ Prefer `:moved_permanently` over `301` to define HTTP status code.
        redirect_to action: 'index', status: 301
                                             ^^^ Prefer `:moved_permanently` over `301` to define HTTP status code.
        redirect_to root_path(utm_source: :pr, utm_medium: :web), status: 301
                                                                          ^^^ Prefer `:moved_permanently` over `301` to define HTTP status code.
        head 200
             ^^^ Prefer `:ok` over `200` to define HTTP status code.
        head 200, location: 'accounts'
             ^^^ Prefer `:ok` over `200` to define HTTP status code.
        assert_response 200
                        ^^^ Prefer `:ok` over `200` to define HTTP status code.
        assert_response 404, 'message'
                        ^^^ Prefer `:not_found` over `404` to define HTTP status code.
        assert_redirected_to '/some/path', status: 301
                                                   ^^^ Prefer `:moved_permanently` over `301` to define HTTP status code.
        assert_redirected_to action: 'index', status: 301
                                                      ^^^ Prefer `:moved_permanently` over `301` to define HTTP status code.
        assert_redirected_to '/some/path', { status: 301 }, 'message'
                                                     ^^^ Prefer `:moved_permanently` over `301` to define HTTP status code.
      RUBY

      expect_correction(<<~RUBY)
        render :foo, status: :ok
        render json: { foo: 'bar' }, status: :not_found
        render status: :not_found, json: { foo: 'bar' }
        render plain: 'foo/bar', status: :not_modified
        redirect_to root_url, status: :moved_permanently
        redirect_to action: 'index', status: :moved_permanently
        redirect_to root_path(utm_source: :pr, utm_medium: :web), status: :moved_permanently
        head :ok
        head :ok, location: 'accounts'
        assert_response :ok
        assert_response :not_found, 'message'
        assert_redirected_to '/some/path', status: :moved_permanently
        assert_redirected_to action: 'index', status: :moved_permanently
        assert_redirected_to '/some/path', { status: :moved_permanently }, 'message'
      RUBY
    end

    it 'registers an offense and corrects using numeric string value' do
      expect_offense(<<~RUBY)
        render :foo, status: '200'
                             ^^^^^ Prefer `:ok` over `200` to define HTTP status code.
      RUBY

      expect_correction(<<~RUBY)
        render :foo, status: :ok
      RUBY
    end

    it 'does not register an offense when using symbolic value' do
      expect_no_offenses(<<~RUBY)
        render :foo, status: :ok
        render json: { foo: bar }, status: :not_found
        render plain: 'foo/bar', status: :not_modified
        redirect_to root_url, status: :moved_permanently
        redirect_to root_path(utm_source: :pr, utm_medium: :web), status: :moved_permanently
        head :ok
        assert_response :ok
        assert_response :not_found, 'message'
        assert_redirected_to '/some/path', status: :moved_permanently
        assert_redirected_to action: 'index', status: :moved_permanently
      RUBY
    end

    it 'does not register an offense when using custom HTTP code' do
      expect_no_offenses(<<~RUBY)
        render :foo, status: 550
        render json: { foo: bar }, status: 550
        render plain: 'foo/bar', status: 550
        redirect_to root_url, status: 550
        redirect_to root_path(utm_source: :pr, utm_medium: :web), status: 550
        head 550
        assert_response 550
        assert_response 550, 'message'
        assert_redirected_to '/some/path', status: 550
        assert_redirected_to action: 'index', status: 550
      RUBY
    end

    it 'does not register an offense when using numeric value for `redirect`' do
      expect_no_offenses(<<~RUBY)
        get '/foobar', to: redirect('/foobar/baz', status: 301)
      RUBY
    end
  end

  context 'when EnforcedStyle is `numeric`' do
    let(:cop_config) { { 'EnforcedStyle' => 'numeric' } }

    it 'registers an offense when using symbolic value' do
      expect_offense(<<~RUBY)
        render :foo, status: :ok
                             ^^^ Prefer `200` over `:ok` to define HTTP status code.
        render json: { foo: 'bar' }, status: :not_found
                                             ^^^^^^^^^^ Prefer `404` over `:not_found` to define HTTP status code.
        render status: :not_found, json: { foo: 'bar' }
                       ^^^^^^^^^^ Prefer `404` over `:not_found` to define HTTP status code.
        render plain: 'foo/bar', status: :not_modified
                                         ^^^^^^^^^^^^^ Prefer `304` over `:not_modified` to define HTTP status code.
        redirect_to root_url, status: :moved_permanently
                                      ^^^^^^^^^^^^^^^^^^ Prefer `301` over `:moved_permanently` to define HTTP status code.
        redirect_to action: 'index', status: :moved_permanently
                                             ^^^^^^^^^^^^^^^^^^ Prefer `301` over `:moved_permanently` to define HTTP status code.
        redirect_to root_path(utm_source: :pr, utm_medium: :web), status: :moved_permanently
                                                                          ^^^^^^^^^^^^^^^^^^ Prefer `301` over `:moved_permanently` to define HTTP status code.
        head :ok
             ^^^ Prefer `200` over `:ok` to define HTTP status code.
        head :ok, location: 'accounts'
             ^^^ Prefer `200` over `:ok` to define HTTP status code.
        assert_response :ok
                        ^^^ Prefer `200` over `:ok` to define HTTP status code.
        assert_response :not_found, 'message'
                        ^^^^^^^^^^ Prefer `404` over `:not_found` to define HTTP status code.
        assert_redirected_to '/some/path', status: :moved_permanently
                                                   ^^^^^^^^^^^^^^^^^^ Prefer `301` over `:moved_permanently` to define HTTP status code.
        assert_redirected_to action: 'index', status: :moved_permanently
                                                      ^^^^^^^^^^^^^^^^^^ Prefer `301` over `:moved_permanently` to define HTTP status code.
        assert_redirected_to '/some/path', { status: :moved_permanently }, 'message'
                                                     ^^^^^^^^^^^^^^^^^^ Prefer `301` over `:moved_permanently` to define HTTP status code.
      RUBY

      expect_correction(<<~RUBY)
        render :foo, status: 200
        render json: { foo: 'bar' }, status: 404
        render status: 404, json: { foo: 'bar' }
        render plain: 'foo/bar', status: 304
        redirect_to root_url, status: 301
        redirect_to action: 'index', status: 301
        redirect_to root_path(utm_source: :pr, utm_medium: :web), status: 301
        head 200
        head 200, location: 'accounts'
        assert_response 200
        assert_response 404, 'message'
        assert_redirected_to '/some/path', status: 301
        assert_redirected_to action: 'index', status: 301
        assert_redirected_to '/some/path', { status: 301 }, 'message'
      RUBY
    end

    it 'does not register an offense when using numeric value' do
      expect_no_offenses(<<~RUBY)
        render :foo, status: 200
        render json: { foo: bar }, status: 404
        render plain: 'foo/bar', status: 304
        redirect_to root_url, status: 301
        redirect_to root_path(utm_source: :pr, utm_medium: :web), status: 301
        head 200
        assert_response 200
        assert_response 404, 'message'
        assert_redirected_to '/some/path', status: 301
        assert_redirected_to action: 'index', status: 301
      RUBY
    end

    it 'does not register an offense when using allowed symbols' do
      expect_no_offenses(<<~RUBY)
        render :foo, status: :error
        render :foo, status: :success
        render :foo, status: :missing
        render :foo, status: :redirect
        assert_response :error
        assert_response :success
        assert_response :missing
        assert_response :redirect
      RUBY
    end

    it 'does not register an offense when using symbolic value that have no numeric value mapping' do
      expect_no_offenses(<<~RUBY)
        render json: { foo: 'bar' }, status: :ng
      RUBY
    end
  end
end
