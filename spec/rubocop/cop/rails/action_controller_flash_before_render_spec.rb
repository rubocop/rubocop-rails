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
          end

          it 'does not register an offense when using `flash` before `redirect_to`' do
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
                  if condition
                    flash[:alert] = "msg"
                  end

                  redirect_back fallback_location: root_path
                end
              end
            RUBY
          end

          it 'registers an offense when using `flash` in multiline `if` branch before `render_to`' do
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

  context 'when using `flash` after `render` and `redirect_to` is used in implicit return branch ' \
          'and render is is used in the other branch' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if foo.update(params)
              flash[:success] = 'msg'

              if redirect_to_index?
                redirect_to index
              else
                redirect_to path(foo)
              end
            else
              flash.now[:alert] = 'msg'
              render :edit, status: :unprocessable_entity
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` after `render` and `render` is part of a different preceding branch' \
          'that implicitly returns' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if remote_request? || sandbox?
              if current_user.nil?
                render :index
              else
                head :forbidden
              end
            elsif current_user.nil?
              redirect_to sign_in_path
            else
              flash[:alert] = 'msg'
              if request.referer.present?
                redirect_to(request.referer)
              else
                redirect_to(root_path)
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in `rescue` and `redirect_to` in `ensure`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
          rescue
            flash[:alert] = 'msg'
          ensure
            redirect_to :index
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a one-line iteration block before `redirect_to`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            messages = %w[foo bar baz]
            messages.each { |message| flash[:alert] = message }

            redirect_to :index
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a multi-line block before `redirect_to`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            messages = %w[foo bar baz]
            messages.each do |message|
              flash[:alert] = message
            end

            redirect_to :index
          end
        end
      RUBY
    end
  end
end
