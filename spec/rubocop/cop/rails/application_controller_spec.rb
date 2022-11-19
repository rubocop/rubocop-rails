# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ApplicationController, :config do
  it 'allows `ApplicationController` to be defined' do
    expect_no_offenses(<<~RUBY)
      class ApplicationController < ActionController::Base; end
    RUBY
  end

  it 'allows `ApplicationController` to be defined using Class.new' do
    expect_no_offenses(<<~RUBY)
      ApplicationController = Class.new(ActionController::Base)
    RUBY
  end

  it 'corrects controllers that subclass `ActionController::Base`' do
    expect_offense(<<~RUBY)
      class MyController < ActionController::Base; end
                           ^^^^^^^^^^^^^^^^^^^^^^ Controllers should subclass `ApplicationController`.
    RUBY

    expect_correction(<<~RUBY)
      class MyController < ApplicationController; end
    RUBY
  end

  it 'corrects controllers that subclass `::ActionController::Base`' do
    expect_offense(<<~RUBY)
      class MyController < ::ActionController::Base; end
                           ^^^^^^^^^^^^^^^^^^^^^^^^ Controllers should subclass `ApplicationController`.
    RUBY

    expect_correction(<<~RUBY)
      class MyController < ApplicationController; end
    RUBY
  end

  it 'corrects controllers defined in module namespaces' do
    expect_offense(<<~RUBY)
      module Nested
        class MyController < ActionController::Base; end
                             ^^^^^^^^^^^^^^^^^^^^^^ Controllers should subclass `ApplicationController`.
      end
    RUBY

    expect_correction(<<~RUBY)
      module Nested
        class MyController < ApplicationController; end
      end
    RUBY
  end

  it 'corrects controllers defined in inline namespaces' do
    expect_offense(<<~RUBY)
      class Nested::MyController < ActionController::Base; end
                                   ^^^^^^^^^^^^^^^^^^^^^^ Controllers should subclass `ApplicationController`.
    RUBY

    expect_correction(<<~RUBY)
      class Nested::MyController < ApplicationController; end
    RUBY
  end

  it 'corrects controllers defined using Class.new' do
    expect_offense(<<~RUBY)
      MyController = Class.new(ActionController::Base)
                               ^^^^^^^^^^^^^^^^^^^^^^ Controllers should subclass `ApplicationController`.
    RUBY

    expect_correction(<<~RUBY)
      MyController = Class.new(ApplicationController)
    RUBY
  end

  it 'corrects nested controllers defined using Class.new' do
    expect_offense(<<~RUBY)
      Nested::MyController = Class.new(ActionController::Base)
                                       ^^^^^^^^^^^^^^^^^^^^^^ Controllers should subclass `ApplicationController`.
    RUBY

    expect_correction(<<~RUBY)
      Nested::MyController = Class.new(ApplicationController)
    RUBY
  end

  it 'corrects anonymous controllers' do
    expect_offense(<<~RUBY)
      Class.new(ActionController::Base) {}
                ^^^^^^^^^^^^^^^^^^^^^^ Controllers should subclass `ApplicationController`.
    RUBY

    expect_correction(<<~RUBY)
      Class.new(ApplicationController) {}
    RUBY
  end
end
