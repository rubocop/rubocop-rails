# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::FindByOrAssignmentMemoization, :config do
  context 'when using `find_by` with `||=`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        @current_user ||= User.find_by(id: session[:user_id])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid memoizing `find_by` results with `||=`.
      RUBY

      expect_correction(<<~RUBY)
        return @current_user if defined?(@current_user)

        @current_user = User.find_by(id: session[:user_id])
      RUBY
    end
  end

  context 'with `find_by!`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        @current_user ||= User.find_by!(id: session[:user_id])
      RUBY
    end
  end

  context 'with local variable' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        current_user ||= User.find_by(id: session[:user_id])
      RUBY
    end
  end

  context 'with `||`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        @current_user ||= User.find_by(id: session[:user_id]) || User.anonymous
      RUBY
    end
  end

  context 'with ternary operator' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        @current_user ||= session[:user_id] ? User.find_by(id: session[:user_id]) : nil
      RUBY
    end
  end

  context 'with `if`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
      RUBY
    end
  end

  context 'with `unless`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        @current_user ||= User.find_by(id: session[:user_id]) unless session[:user_id].nil?
      RUBY
    end
  end
end
