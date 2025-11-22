# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RedirectBackOrTo, :config do
  context 'Rails >= 7.0', :rails70 do
    it 'registers an offense and corrects when using redirect_back with a fallback_location' do
      expect_offense(<<~RUBY)
        redirect_back(fallback_location: root_path)
        ^^^^^^^^^^^^^ Use `redirect_back_or_to` instead of `redirect_back` with `:fallback_location` keyword argument.
      RUBY

      expect_correction(<<~RUBY)
        redirect_back_or_to(root_path)
      RUBY
    end

    it 'registers an offense and corrects with additional options' do
      expect_offense(<<~RUBY)
        redirect_back(fallback_location: root_path, status: 303, allow_other_host: true)
        ^^^^^^^^^^^^^ Use `redirect_back_or_to` instead of `redirect_back` with `:fallback_location` keyword argument.
      RUBY

      expect_correction(<<~RUBY)
        redirect_back_or_to(root_path, status: 303, allow_other_host: true)
      RUBY
    end

    it 'registers an offense and corrects with additional options as double splat' do
      expect_offense(<<~RUBY)
        redirect_back(fallback_location: root_path, **options)
        ^^^^^^^^^^^^^ Use `redirect_back_or_to` instead of `redirect_back` with `:fallback_location` keyword argument.
      RUBY

      expect_correction(<<~RUBY)
        redirect_back_or_to(root_path, **options)
      RUBY
    end

    it 'registers an offense and corrects when `fallback_location` arg is a hash and the call has no arg parentheses' do
      expect_offense(<<~RUBY)
        redirect_back fallback_location: {action: 'index'}
        ^^^^^^^^^^^^^ Use `redirect_back_or_to` instead of `redirect_back` with `:fallback_location` keyword argument.
      RUBY

      expect_correction(<<~RUBY)
        redirect_back_or_to({action: 'index'})
      RUBY
    end

    it 'registers an offense and corrects when `fallback_location` arg is a hash and the call uses arg parentheses' do
      expect_offense(<<~RUBY)
        redirect_back(fallback_location: {action: 'index'})
        ^^^^^^^^^^^^^ Use `redirect_back_or_to` instead of `redirect_back` with `:fallback_location` keyword argument.
      RUBY

      expect_correction(<<~RUBY)
        redirect_back_or_to({action: 'index'})
      RUBY
    end

    it 'registers no offense when using redirect_back_or_to' do
      expect_no_offenses(<<~RUBY)
        redirect_back_or_to(root_path)
      RUBY
    end

    it 'registers no offense when using redirect_back without fallback_location' do
      expect_no_offenses(<<~RUBY)
        redirect_back(allow_other_host: false)
      RUBY
    end
  end

  context 'Rails <= 6.1', :rails61 do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        redirect_back(fallback_location: root_path)
      RUBY
    end
  end
end
