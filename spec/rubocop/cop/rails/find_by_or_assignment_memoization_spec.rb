# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::FindByOrAssignmentMemoization, :config do
  context 'when using `find_by` with `||=`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        @current_user ||= User.find_by(id: session[:user_id])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid memoizing `find_by` results with `||=`.
      RUBY

      expect_correction(<<~RUBY)
        if defined?(@current_user)
          @current_user
        else
          @current_user = User.find_by(id: session[:user_id])
        end
      RUBY
    end
  end

  context 'when using `find_by` with `||=` in a method body' do
    it 'registers an offense when not assigning the instance variable in the `initialize` method' do
      expect_offense(<<~RUBY)
        class Foo
          def initialize
            @not_current_user = nil
          end

          def current_user
            @current_user ||= User.find_by(id: session[:user_id])
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid memoizing `find_by` results with `||=`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          def initialize
            @not_current_user = nil
          end

          def current_user
            return @current_user if defined?(@current_user)

        @current_user = User.find_by(id: session[:user_id])
          end
        end
      RUBY
    end

    it 'does not register an offense when assigning the instance variable in the `initialize` method' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def initialize
            @current_user = nil
          end

          def current_user
            @current_user ||= User.find_by(id: session[:user_id])
          end
        end
      RUBY
    end

    it 'registers an offense when the method contains other code' do
      expect_offense(<<~RUBY)
        def current_user
          @current_user ||= User.find_by(id: session[:user_id])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid memoizing `find_by` results with `||=`.

          @current_user.do_something!
        end
      RUBY

      expect_correction(<<~RUBY)
        def current_user
          if defined?(@current_user)
          @current_user
        else
          @current_user = User.find_by(id: session[:user_id])
        end

          @current_user.do_something!
        end
      RUBY
    end

    it 'registers an offense when using endless method definition', :ruby30 do
      expect_offense(<<~RUBY)
        def current_user(arg) = @current_user ||= User.find_by(id: session[:user_id])
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid memoizing `find_by` results with `||=`.
      RUBY

      expect_correction(<<~RUBY)
        def current_user(arg)#{' '}
        return @current_user if defined?(@current_user)

        @current_user = User.find_by(id: session[:user_id])
        end
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
