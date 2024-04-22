# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::LexicallyScopedActionFilter, :config do
  it 'registers an offense when string node method is not defined' do
    expect_offense <<~RUBY
      class LoginController < ApplicationController
        before_action :require_login, except: 'health_check'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `health_check` is not explicitly defined on the class.

        def index
        end
      end
    RUBY
  end

  it 'registers an offense when symbol node method is not defined' do
    expect_offense <<~RUBY
      class LoginController < ApplicationController
        skip_before_action :require_login, only: :health_check
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `health_check` is not explicitly defined on the class.

        def index
        end
      end
    RUBY
  end

  it 'registers an offense when array string node methods are not defined' do
    expect_offense <<~RUBY
      class LoginController < ApplicationController
        before_action :require_login, only: %w[index settings]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `settings` is not explicitly defined on the class.

        def index
        end
      end
    RUBY
  end

  it 'registers an offense when array symbol node methods are not defined' do
    expect_offense <<~RUBY
      class LoginController < ApplicationController
        before_action :require_login, only: %i[index settings logout]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `settings`, `logout` are not explicitly defined on the class.

        def index
        end
      end
    RUBY
  end

  it 'registers an offense when no methods are defined' do
    expect_offense <<~RUBY
      class LoginController < ApplicationController
        before_action :require_login, only: %i[index show]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `index`, `show` are not explicitly defined on the class.
      end
    RUBY
  end

  it 'registers an offense when using action filter in module' do
    expect_offense <<~RUBY
      module FooMixin
        extend ActiveSupport::Concern

        included do
          before_action proc { authenticate }, only: :foo
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `foo` is not explicitly defined on the module.
        end
      end
    RUBY
  end

  it "doesn't register an offense when string node method is defined" do
    expect_no_offenses <<~RUBY
      class LoginController < ApplicationController
        before_action :require_login, except: 'health_check'

        def health_check
        end
      end
    RUBY
  end

  it "doesn't register an offense when symbol node method is defined" do
    expect_no_offenses <<~RUBY
      class LoginController < ApplicationController
        skip_before_action :require_login, only: :health_check

        def health_check
        end
      end
    RUBY
  end

  it "doesn't register an offense when array string node methods are defined" do
    expect_no_offenses <<~RUBY
      class LoginController < ApplicationController
        before_action :require_login, only: %w[index settings]

        def index
        end

        def settings
        end
      end
    RUBY
  end

  it "doesn't register an offense when array symbol node methods are defined" do
    expect_no_offenses <<~RUBY
      class LoginController < ApplicationController
        before_action :require_login, only: %i[index settings logout]

        def index
        end

        def settings
        end

        def logout
        end
      end
    RUBY
  end

  it 'does not register an offense when action method is aliased by `alias_method`' do
    expect_no_offenses(<<~RUBY)
      class FooController < ApplicationController
        before_action :authorize!, only: %i[index show]

        def index
        end
        alias_method :show, :index

        private

        def authorize!
        end
      end
    RUBY
  end

  it 'registers an offense when action method is not aliased by `alias_method`' do
    expect_offense(<<~RUBY)
      class FooController < ApplicationController
        before_action :authorize!, only: %i[foo show]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `foo` is not explicitly defined on the class.

        def index
        end
        alias_method :show, :index

        private

        def authorize!
        end
      end
    RUBY
  end

  it 'does not register an offense when action method is aliased by `alias`' do
    expect_no_offenses(<<~RUBY)
      class FooController < ApplicationController
        before_action :authorize!, only: %i[index show]

        def index
        end
        alias show index

        private

        def authorize!
        end
      end
    RUBY
  end

  it 'registers an offense when action method is not aliased by `alias`' do
    expect_offense(<<~RUBY)
      class FooController < ApplicationController
        before_action :authorize!, only: %i[foo show]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `foo` is not explicitly defined on the class.

        def index
        end
        alias show index

        private

        def authorize!
        end
      end
    RUBY
  end

  it "doesn't register an offense when using conditional statements" do
    expect_no_offenses <<~RUBY
      class Test < ActionController
        before_action(:authenticate, only: %i[update cancel]) unless foo

        def update; end

        def cancel; end
      end
    RUBY
  end

  it "doesn't register an offense when using mixin" do
    expect_no_offenses <<~RUBY
      module FooMixin
        extend ActiveSupport::Concern

        included do
          before_action proc { authenticate }, only: :foo
        end

        def foo; end
      end
    RUBY
  end

  it "doesn't register an offense when using %I literal" do
    expect_no_offenses <<~RUBY
      class FooController < ApplicationController
        before_action :foo, except: %I[index show]

        def index
        end

        def show
        end
      end
    RUBY
  end
end
