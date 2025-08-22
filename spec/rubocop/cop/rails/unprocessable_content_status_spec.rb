# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::UnprocessableContentStatus, :config do
  context 'when Rack is older than 3.1 or not available' do
    before do
      allow(cop).to receive(:rack_3_1_or_newer?).and_return(false)
    end

    it 'does nothing' do
      expect_no_offenses(<<~RUBY)
        render json: { error: 'Invalid data' }, status: :unprocessable_entity
      RUBY
    end
  end

  context 'when Rack is 3.1 or later' do
    before do
      allow(cop).to receive(:rack_3_1_or_newer?).and_return(true)
    end

    it 'registers an offense when using :unprocessable_entity in hash argument' do
      expect_offense(<<~RUBY)
        render json: { error: 'Invalid data' }, status: :unprocessable_entity
                                                        ^^^^^^^^^^^^^^^^^^^^^ Use `:unprocessable_content` instead of `:unprocessable_entity`. The `:unprocessable_entity` status is deprecated.
      RUBY

      expect_correction(<<~RUBY)
        render json: { error: 'Invalid data' }, status: :unprocessable_content
      RUBY
    end

    it 'registers an offense when using :unprocessable_entity in head' do
      expect_offense(<<~RUBY)
        head :unprocessable_entity
             ^^^^^^^^^^^^^^^^^^^^^ Use `:unprocessable_content` instead of `:unprocessable_entity`. The `:unprocessable_entity` status is deprecated.
      RUBY

      expect_correction(<<~RUBY)
        head :unprocessable_content
      RUBY
    end

    it 'registers an offense when using :unprocessable_entity in ternary expression' do
      expect_offense(<<~RUBY)
        render json: { error: 'Invalid data' }, status: :unprocessable_entity ? :unprocessable_content : :ok
                                                        ^^^^^^^^^^^^^^^^^^^^^ Use `:unprocessable_content` instead of `:unprocessable_entity`. The `:unprocessable_entity` status is deprecated.
      RUBY

      expect_correction(<<~RUBY)
        render json: { error: 'Invalid data' }, status: :unprocessable_content ? :unprocessable_content : :ok
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
  end
end
