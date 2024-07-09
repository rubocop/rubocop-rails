# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActionControllerFlashBeforeRender, :config do
  context 'when using `flash` before `render`' do
    context 'within an instance method' do
      %w[
        ::ActionController::Base
        ::ApplicationController
        ActionController::Base
        ApplicationController
      ].each do |parent_class|
        context "within a class inherited from #{parent_class}" do
          it 'registers an offense and corrects when the render call is explicit' do
            expect_offense(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  flash[:alert] = "msg"
                  ^^^^^ Use `flash.now` before `render`.
                  render :index
                end
              end
            RUBY

            expect_correction(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  flash.now[:alert] = "msg"
                  render :index
                end
              end
            RUBY
          end

          it 'registers an offense and corrects when the render call is implicit' do
            expect_offense(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  flash[:alert] = "msg"
                  ^^^^^ Use `flash.now` before `render`.
                end
              end
            RUBY

            expect_correction(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  flash.now[:alert] = "msg"
                end
              end
            RUBY
          end
        end
      end

      context 'within a non Rails controller class' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class NonController < ApplicationRecord
              def create
                flash[:alert] = "msg"
                render :index
              end
            end
          RUBY
        end
      end
    end

    context 'within a block' do
      %w[ActionController::Base ApplicationController].each do |parent_class|
        context "within a class inherited from #{parent_class}" do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY)
              class HomeController < #{parent_class}
                before_action do
                  flash[:alert] = "msg"
                  ^^^^^ Use `flash.now` before `render`.
                  render :index
                end
              end
            RUBY

            expect_correction(<<~RUBY)
              class HomeController < #{parent_class}
                before_action do
                  flash.now[:alert] = "msg"
                  render :index
                end
              end
            RUBY
          end
        end
      end

      context 'within a non Rails controller class' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class NonController < ApplicationRecord
              before_action do
                flash[:alert] = "msg"
                render :index
              end
            end
          RUBY
        end
      end
    end

    context 'with a condition' do
      %w[ActionController::Base ApplicationController].each do |parent_class|
        context "within a class inherited from #{parent_class}" do
          it 'registers an offense and corrects when using `flash` before `render`' do
            expect_offense(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  flash[:alert] = "msg" if condition
                  ^^^^^ Use `flash.now` before `render`.
                  render :index
                end
              end
            RUBY

            expect_correction(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  flash.now[:alert] = "msg" if condition
                  render :index
                end
              end
            RUBY

            expect_offense(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  flash[:alert] = "msg" if condition
                  ^^^^^ Use `flash.now` before `render`.
                end
              end
            RUBY

            expect_correction(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  flash.now[:alert] = "msg" if condition
                end
              end
            RUBY
          end

          it 'does not register an offense when using `flash` before `redirect_to`' do
            expect_no_offenses(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  flash[:alert] = "msg" if condition

                  redirect_to :index
                end
              end
            RUBY

            expect_no_offenses(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  if condition
                    flash[:alert] = "msg"
                  end

                  redirect_to :index
                end
              end
            RUBY
          end

          it 'does not register an offense when using `flash` before `redirect_back`' do
            expect_no_offenses(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  flash[:alert] = "msg" if condition

                  redirect_back fallback_location: root_path
                end
              end
            RUBY

            expect_no_offenses(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  if condition
                    flash[:alert] = "msg"
                  end

                  redirect_back fallback_location: root_path
                end
              end
            RUBY
          end

          it 'registers an offense when using `flash` in multiline `if` branch before `render`' do
            expect_offense(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  if condition
                    do_something
                    flash[:alert] = "msg"
                    ^^^^^ Use `flash.now` before `render`.
                  end

                  render :index
                end
              end
            RUBY

            expect_correction(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  if condition
                    do_something
                    flash.now[:alert] = "msg"
                  end

                  render :index
                end
              end
            RUBY

            expect_offense(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  if condition
                    do_something
                    flash[:alert] = "msg"
                    ^^^^^ Use `flash.now` before `render`.
                  end
                end
              end
            RUBY

            expect_correction(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  if condition
                    do_something
                    flash.now[:alert] = "msg"
                  end
                end
              end
            RUBY
          end

          it 'does not register an offense when using `flash` in multiline `if` branch before `redirect_to`' do
            expect_no_offenses(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  if condition
                    do_something
                    flash[:alert] = "msg"
                  end

                  redirect_to :index
                end
              end
            RUBY
          end

          it 'does not register an offense when using `flash` before `redirect_to` in `if` branch' do
            expect_no_offenses(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  if condition
                    flash[:alert] = "msg"
                    redirect_to :index

                    return
                  end

                  render :index
                end
              end
            RUBY

            expect_no_offenses(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  if condition
                    flash[:alert] = "msg"
                    redirect_to :index

                    return
                  end
                end
              end
            RUBY
          end

          it 'registers an offense when using `flash` in multiline `rescue` branch before `render`' do
            expect_offense(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  begin
                    do_something
                    flash[:alert] = "msg in begin"
                    ^^^^^ Use `flash.now` before `render`.
                  rescue
                    flash[:alert] = "msg in rescue"
                    ^^^^^ Use `flash.now` before `render`.
                  end

                  render :index
                end
              end
            RUBY

            expect_correction(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  begin
                    do_something
                    flash.now[:alert] = "msg in begin"
                  rescue
                    flash.now[:alert] = "msg in rescue"
                  end

                  render :index
                end
              end
            RUBY

            expect_offense(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  begin
                    do_something
                    flash[:alert] = "msg in begin"
                    ^^^^^ Use `flash.now` before `render`.
                  rescue
                    flash[:alert] = "msg in rescue"
                    ^^^^^ Use `flash.now` before `render`.
                  end
                end
              end
            RUBY

            expect_correction(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  begin
                    do_something
                    flash.now[:alert] = "msg in begin"
                  rescue
                    flash.now[:alert] = "msg in rescue"
                  end
                end
              end
            RUBY
          end

          it 'does not register an offense when using `flash` in multiline `rescue` branch before `redirect_to`' do
            expect_no_offenses(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  begin
                    do_something
                    flash[:alert] = "msg in begin"
                  rescue
                    flash[:alert] = "msg in rescue"
                  end

                  redirect_to :index
                end
              end
            RUBY
          end

          it 'does not register an offense when using `flash` before `redirect_to` in `rescue` branch' do
            expect_no_offenses(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  begin
                    do_something
                    flash[:alert] = "msg in begin"
                    redirect_to :index

                    return
                  rescue
                    flash[:alert] = "msg in rescue"
                    redirect_to :index
 
                    return
                  end

                  render :index
                end
              end
            RUBY

            expect_no_offenses(<<~RUBY)
              class HomeController < #{parent_class}
                def create
                  begin
                    do_something
                    flash[:alert] = "msg in begin"
                    redirect_to :index

                    return
                  rescue
                    flash[:alert] = "msg in rescue"
                    redirect_to :index
 
                    return
                  end
                end
              end
            RUBY
          end
        end
      end

      context 'within a non Rails controller class' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class NonController < ApplicationRecord
              before_action do
                flash[:alert] = "msg"
                render :index
              end
            end
          RUBY
        end
      end
    end

    context 'within a class method' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class HomeController < ApplicationController
            def self.create
              flash[:alert] = "msg"
              render :index
            end
          end
        RUBY
      end
    end

    context 'within a class body' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class HomeController < ApplicationController
            flash[:alert] = "msg"
            render :index
          end
        RUBY
      end
    end

    context 'with no context' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          flash[:alert] = "msg"
          render :index
        RUBY
      end
    end
  end

  context 'when using `flash` before `redirect_to`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            flash[:alert] = "msg"
            redirect_to "https://www.example.com/"
          end
        end
      RUBY
    end
  end

  context 'when using `flash` after `render` but before a `redirect_to`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            render :index and return if foo?
            flash[:alert] = "msg"
            redirect_to "https://www.example.com/"
          end
        end
      RUBY
    end
  end

  context 'when using `flash` after `render` and returning `redirect_to` in condition block' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if condition
              flash[:alert] = "msg"
              return redirect_to "https://www.example.com/"
            end
            render :index
          end
        end
      RUBY
    end
  end
end
