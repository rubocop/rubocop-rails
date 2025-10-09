# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::HttpStatusNameConsistency, :config do
  context 'when Rack is older than 3.1' do
    let(:gem_versions) { { 'rack' => '3.0.0' } }

    it 'does nothing' do
      expect_no_offenses(<<~RUBY)
        render json: { error: 'Invalid data' }, status: :unprocessable_entity
        head :payload_too_large
      RUBY
    end
  end

  context 'when Rack is 3.1 or later' do
    let(:gem_versions) { { 'rack' => '3.1.0' } }

    context 'with :unprocessable_entity' do
      it 'registers an offense when using :unprocessable_entity in render' do
        expect_offense(<<~RUBY)
          render json: { error: 'Invalid data' }, status: :unprocessable_entity
                                                          ^^^^^^^^^^^^^^^^^^^^^ Prefer `:unprocessable_content` over `:unprocessable_entity`.
        RUBY

        expect_correction(<<~RUBY)
          render json: { error: 'Invalid data' }, status: :unprocessable_content
        RUBY
      end

      it 'registers an offense when using :unprocessable_entity in head' do
        expect_offense(<<~RUBY)
          head :unprocessable_entity
               ^^^^^^^^^^^^^^^^^^^^^ Prefer `:unprocessable_content` over `:unprocessable_entity`.
        RUBY

        expect_correction(<<~RUBY)
          head :unprocessable_content
        RUBY
      end

      it 'registers an offense when using :unprocessable_entity in redirect_to' do
        expect_offense(<<~RUBY)
          redirect_to some_path, status: :unprocessable_entity
                                         ^^^^^^^^^^^^^^^^^^^^^ Prefer `:unprocessable_content` over `:unprocessable_entity`.
        RUBY

        expect_correction(<<~RUBY)
          redirect_to some_path, status: :unprocessable_content
        RUBY
      end

      it 'registers an offense when using :unprocessable_entity in assert_response' do
        expect_offense(<<~RUBY)
          assert_response :unprocessable_entity
                          ^^^^^^^^^^^^^^^^^^^^^ Prefer `:unprocessable_content` over `:unprocessable_entity`.
        RUBY

        expect_correction(<<~RUBY)
          assert_response :unprocessable_content
        RUBY
      end

      it 'registers an offense when using :unprocessable_entity in assert_redirected_to' do
        expect_offense(<<~RUBY)
          assert_redirected_to some_path, status: :unprocessable_entity
                                                  ^^^^^^^^^^^^^^^^^^^^^ Prefer `:unprocessable_content` over `:unprocessable_entity`.
        RUBY

        expect_correction(<<~RUBY)
          assert_redirected_to some_path, status: :unprocessable_content
        RUBY
      end

      it 'registers an offense when using :unprocessable_entity in ternary expression' do
        expect_offense(<<~RUBY)
          render json: { error: 'Invalid data' }, status: some_condition ? :unprocessable_entity : :ok
                                                                           ^^^^^^^^^^^^^^^^^^^^^ Prefer `:unprocessable_content` over `:unprocessable_entity`.
        RUBY

        expect_correction(<<~RUBY)
          render json: { error: 'Invalid data' }, status: some_condition ? :unprocessable_content : :ok
        RUBY
      end

      it 'does not register an offense when using :unprocessable_content' do
        expect_no_offenses(<<~RUBY)
          render json: { error: 'Invalid data' }, status: :unprocessable_content
        RUBY
      end

      it 'does not register an offense when using :unprocessable_entity in hash key' do
        expect_no_offenses(<<~RUBY)
          { unprocessable_entity: 'Invalid data' }
        RUBY
      end

      it 'does not register an offense when status is provided via variable' do
        expect_no_offenses(<<~RUBY)
          status_var = :unprocessable_entity
          head status_var
          render json: { error: 'Invalid data' }, status: status_var
          redirect_to some_path, status: status_var
          assert_response status_var
        RUBY
      end

      it 'does not register an offense when status is provided via method call' do
        expect_no_offenses(<<~RUBY)
          head get_status_code
          render json: { error: 'Invalid data' }, status: calculate_status
        RUBY
      end
    end

    context 'with :payload_too_large' do
      it 'registers an offense when using :payload_too_large in render' do
        expect_offense(<<~RUBY)
          render json: { error: 'File too big' }, status: :payload_too_large
                                                          ^^^^^^^^^^^^^^^^^^ Prefer `:content_too_large` over `:payload_too_large`.
        RUBY

        expect_correction(<<~RUBY)
          render json: { error: 'File too big' }, status: :content_too_large
        RUBY
      end

      it 'registers an offense when using :payload_too_large in head' do
        expect_offense(<<~RUBY)
          head :payload_too_large
               ^^^^^^^^^^^^^^^^^^ Prefer `:content_too_large` over `:payload_too_large`.
        RUBY

        expect_correction(<<~RUBY)
          head :content_too_large
        RUBY
      end

      it 'registers an offense when using :payload_too_large in redirect_to' do
        expect_offense(<<~RUBY)
          redirect_to some_path, status: :payload_too_large
                                         ^^^^^^^^^^^^^^^^^^ Prefer `:content_too_large` over `:payload_too_large`.
        RUBY

        expect_correction(<<~RUBY)
          redirect_to some_path, status: :content_too_large
        RUBY
      end

      it 'registers an offense when using :payload_too_large in assert_response' do
        expect_offense(<<~RUBY)
          assert_response :payload_too_large
                          ^^^^^^^^^^^^^^^^^^ Prefer `:content_too_large` over `:payload_too_large`.
        RUBY

        expect_correction(<<~RUBY)
          assert_response :content_too_large
        RUBY
      end

      it 'registers an offense when using :payload_too_large in assert_redirected_to' do
        expect_offense(<<~RUBY)
          assert_redirected_to some_path, status: :payload_too_large
                                                  ^^^^^^^^^^^^^^^^^^ Prefer `:content_too_large` over `:payload_too_large`.
        RUBY

        expect_correction(<<~RUBY)
          assert_redirected_to some_path, status: :content_too_large
        RUBY
      end

      it 'registers an offense when using :payload_too_large in ternary expression' do
        expect_offense(<<~RUBY)
          render json: { error: 'File too big' }, status: some_condition ? :payload_too_large : :ok
                                                                           ^^^^^^^^^^^^^^^^^^ Prefer `:content_too_large` over `:payload_too_large`.
        RUBY

        expect_correction(<<~RUBY)
          render json: { error: 'File too big' }, status: some_condition ? :content_too_large : :ok
        RUBY
      end

      it 'does not register an offense when using :content_too_large' do
        expect_no_offenses(<<~RUBY)
          render json: { error: 'File too big' }, status: :content_too_large
        RUBY
      end

      it 'does not register an offense when using :payload_too_large in hash key' do
        expect_no_offenses(<<~RUBY)
          { payload_too_large: 'File too big' }
        RUBY
      end

      it 'does not register an offense when status is provided via variable' do
        expect_no_offenses(<<~RUBY)
          status_var = :payload_too_large
          head status_var
          render json: { error: 'Invalid data' }, status: status_var
          redirect_to some_path, status: status_var
          assert_response status_var
        RUBY
      end

      it 'does not register an offense when status is provided via method call' do
        expect_no_offenses(<<~RUBY)
          head get_status_code
          render json: { error: 'Invalid data' }, status: calculate_status
        RUBY
      end
    end

    context 'with partial preferred statuses' do
      it 'handles status preference in the same code' do
        expect_offense(<<~RUBY)
          head :unprocessable_entity
               ^^^^^^^^^^^^^^^^^^^^^ Prefer `:unprocessable_content` over `:unprocessable_entity`.
          head :payload_too_large
               ^^^^^^^^^^^^^^^^^^ Prefer `:content_too_large` over `:payload_too_large`.
        RUBY

        expect_correction(<<~RUBY)
          head :unprocessable_content
          head :content_too_large
        RUBY
      end
    end
  end
end
