# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActionOrder, :config do
  it 'detects unconventional order of actions' do
    expect_offense(<<~RUBY)
      class UserController < ApplicationController
        def show; end
        def index; end
        ^^^^^^^^^^^^^^ Action `index` should appear before `show`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class UserController < ApplicationController
        def index; end
        def show; end
      end
    RUBY
  end

  it 'detects unconventional order of multiple actions' do
    expect_offense(<<~RUBY)
      class UserController < ApplicationController
        def create; end
        def edit; end
        ^^^^^^^^^^^^^ Action `edit` should appear before `create`.
        def show; end
        ^^^^^^^^^^^^^ Action `show` should appear before `edit`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class UserController < ApplicationController
        def show; end
        def edit; end
        def create; end
      end
    RUBY
  end

  it 'supports methods with content' do
    expect_offense(<<~RUBY)
      class UserController < ApplicationController
        def show
          @user = User.find(params[:id])
        end

        def index; end
        ^^^^^^^^^^^^^^ Action `index` should appear before `show`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class UserController < ApplicationController
        def index; end
        def show
          @user = User.find(params[:id])
        end

      end
    RUBY
  end

  it 'respects order of duplicate methods' do
    expect_offense(<<~RUBY)
      class UserController < ApplicationController
        def edit; end
        def index # first
        ^^^^^^^^^^^^^^^^^ Action `index` should appear before `edit`.
        end
        def show; end
        def index # second
        ^^^^^^^^^^^^^^^^^^ Action `index` should appear before `show`.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class UserController < ApplicationController
        def index # first
        end
        def index # second
        end
        def show; end
        def edit; end
      end
    RUBY
  end

  it 'ignores non standard controller actions' do
    expect_no_offenses(<<~RUBY)
      class UserController < ApplicationController
        def index; end
        def commit; end
        def show; end
      end
    RUBY
  end

  it 'does not touch protected actions' do
    expect_no_offenses(<<~RUBY)
      class UserController < ApplicationController
        def show; end
        protected
        def index; end
      end
    RUBY
  end

  it 'does not touch inline protected actions' do
    expect_no_offenses(<<~RUBY)
      class UserController < ApplicationController
        def show; end
        protected def index; end
      end
    RUBY
  end

  it 'does not touch private actions' do
    expect_no_offenses(<<~RUBY)
      class UserController < ApplicationController
        def show; end
        private
        def index; end
      end
    RUBY
  end

  it 'does not touch inline private actions' do
    expect_no_offenses(<<~RUBY)
      class UserController < ApplicationController
        def show; end
        private def index; end
      end
    RUBY
  end

  it 'detects unconventional order of actions in conditions' do
    expect_offense(<<~RUBY)
      class TestController < BaseController
        unless Rails.env.development?
          def edit
          end
        end

        if Rails.env.development?
          def index
          ^^^^^^^^^ Action `index` should appear before `edit`.
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class TestController < BaseController
        if Rails.env.development?
          def index
          end
        end
        unless Rails.env.development?
          def edit
          end
        end

      end
    RUBY
  end

  context 'with custom ordering' do
    it 'enforces custom order' do
      cop_config['ExpectedOrder'] = %w[show index new edit create update destroy]

      expect_offense(<<~RUBY)
        class UserController < ApplicationController
          def index; end
          def show; end
          ^^^^^^^^^^^^^ Action `show` should appear before `index`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class UserController < ApplicationController
          def show; end
          def index; end
        end
      RUBY
    end

    it 'does not require all actions to be specified' do
      cop_config['ExpectedOrder'] = %w[show index]

      expect_offense(<<~RUBY)
        class UserController < ApplicationController
          def index; end
          def edit; end
          def show; end
          ^^^^^^^^^^^^^ Action `show` should appear before `index`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class UserController < ApplicationController
          def show; end
          def index; end
          def edit; end
        end
      RUBY
    end
  end

  context 'when action has some comments' do
    it 'corrects comments properly' do
      expect_offense(<<~RUBY)
        class UserController < ApplicationController
          # show
          def show; end

          # index
          def index; end
          ^^^^^^^^^^^^^^ Action `index` should appear before `show`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class UserController < ApplicationController
          # index
          def index; end
          # show
          def show; end

        end
      RUBY
    end
  end

  it 'corrects order of resources only argument' do
    expect_offense(<<~RUBY)
      resources :books, only: [:show, :index]
                                      ^^^^^^ Action `index` should appear before `show`.
    RUBY

    expect_correction(<<~RUBY)
      resources :books, only: [:index, :show]
    RUBY
  end

  it 'corrects order of resources except argument' do
    expect_offense(<<~RUBY)
      resources :books, except: [:update, :edit]
                                          ^^^^^ Action `edit` should appear before `update`.
    RUBY

    expect_correction(<<~RUBY)
      resources :books, except: [:edit, :update]
    RUBY
  end

  it 'corrects order of resources both only and except argument' do
    expect_offense(<<~RUBY)
      resources :books, only: [:show, :index], except: [:update, :edit]
                                                                 ^^^^^ Action `edit` should appear before `update`.
                                      ^^^^^^ Action `index` should appear before `show`.
    RUBY

    expect_correction(<<~RUBY)
      resources :books, only: [:index, :show], except: [:edit, :update]
    RUBY
  end

  it 'has no offenses for resources with arguments in standard order' do
    expect_no_offenses(<<~RUBY)
      resources :books, only: [:index, :show], except: [:edit, :update]
    RUBY
  end
end
