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

  context 'when using `flash` before `redirect_to ... and return` in condition block and `render` in a later branch' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def update
            if condition
              flash[:danger] = "msg"
              redirect_to root_path and return
            end

            if other_condition
              flash[:success] = "other msg"
              redirect_to root_path
            else
              flash.now[:danger] = "other other msg"
              render 'something', status: :unprocessable_entity
            end
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

  context 'when using `flash` in `rescue` and `render` in `ensure`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            do_something
          rescue StandardError
            flash[:alert] = "msg"
            ^^^^^ Use `flash.now` before `render`.
          ensure
            render :new
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            do_something
          rescue StandardError
            flash.now[:alert] = "msg"
          ensure
            render :new
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a conditional and `render` in `rescue`' do
    it 'does not register an offense when a statement after `flash` can only reach `render` by raising an exception' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if params[:notify]
              flash[:notice] = "msg"
              Notifier.deliver!(current_user)
            end
          rescue Notifier::Error
            render :new
          end
        end
      RUBY
    end

    it 'does not register an offense when `flash` is the last statement' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if params[:notify]
              Notifier.deliver!(current_user)
              flash[:notice] = "msg"
            end
          rescue Notifier::Error
            render :new
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in nested conditionals' do
    it 'registers an offense when `render` follows the outer conditional' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @user
              if @user.save
                flash[:notice] = "msg"
                ^^^^^ Use `flash.now` before `render`.
              end
            end
            render :new
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @user
              if @user.save
                flash.now[:notice] = "msg"
              end
            end
            render :new
          end
        end
      RUBY
    end

    it 'does not register an offense when `redirect_to` follows the inner conditional' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @user
              if @user.save
                flash[:notice] = "msg"
              end
              redirect_to :index
            end
            render :new
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in an `if` branch and `redirect_to` only in the `else` branch' do
    it 'registers an offense when `render` follows the conditional' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @user.save
              flash[:notice] = "msg"
              ^^^^^ Use `flash.now` before `render`.
            else
              redirect_to :index
            end
            render :show
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @user.save
              flash.now[:notice] = "msg"
            else
              redirect_to :index
            end
            render :show
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a method defined in a conditional' do
    it 'registers an offense when `render` follows `flash`' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          if Rails.env.development?
            def create
              flash[:notice] = "msg"
              ^^^^^ Use `flash.now` before `render`.
              render :new
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          if Rails.env.development?
            def create
              flash.now[:notice] = "msg"
              render :new
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before `redirect_back` in a conditional and `render` after it' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def update
            if @post.update(post_params)
              flash[:notice] = "msg"
              redirect_back(fallback_location: root_path) and return
            end
            render :edit
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before `redirect_back_or_to` in a conditional and `render` after it' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def update
            if @post.update(post_params)
              flash[:notice] = "msg"
              redirect_back_or_to(root_path) and return
            end
            render :edit
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before `return`' do
    it 'does not register an offense when `render` comes only after the `return`' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @event.closed?
              redirect_to event_path(@event)
              flash[:danger] = "msg"
              return
            end
            render :new
          end
        end
      RUBY
    end

    it 'registers an offense when `render` is in an `ensure` branch that runs after the `return`' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              flash[:notice] = "msg"
              ^^^^^ Use `flash.now` before `render`.
              return
            ensure
              render :new
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              flash.now[:notice] = "msg"
              return
            ensure
              render :new
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before `raise`' do
    it 'does not register an offense when `render` comes only after the `raise`' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def show
            if @user.nil?
              flash[:alert] = "msg"
              raise ActiveRecord::RecordNotFound
            end
            render :show
          end
        end
      RUBY
    end

    it 'does not register an offense when `render` is in an `ensure` branch that runs while raising' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def show
            begin
              flash[:alert] = "msg"
              raise ActiveRecord::RecordNotFound
            ensure
              render :show
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before `raise ActiveRecord::Rollback`' do
    it 'registers an offense when `render` follows the `transaction`' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def update
            Post.transaction do
              @posts.each do |post|
                unless post.update(post_params)
                  flash[:error] = "msg"
                  ^^^^^ Use `flash.now` before `render`.
                  raise ActiveRecord::Rollback
                end
              end
              redirect_to posts_path
              return
            end
            render :index
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def update
            Post.transaction do
              @posts.each do |post|
                unless post.update(post_params)
                  flash.now[:error] = "msg"
                  raise ActiveRecord::Rollback
                end
              end
              redirect_to posts_path
              return
            end
            render :index
          end
        end
      RUBY
    end

    it 'does not register an offense outside `transaction`' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def update
            if @post.invalid?
              flash[:error] = "msg"
              raise ActiveRecord::Rollback
            end
            render :edit
          end
        end
      RUBY
    end

    it 'does not register an offense when `render` is in an `ensure` branch outside `transaction`' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def update
            begin
              flash[:error] = "msg"
              raise ActiveRecord::Rollback
            ensure
              render :edit
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before `break` in a block' do
    it 'does not register an offense when `render` comes only in the rest of the block' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            items.each do |item|
              if item.invalid?
                flash[:alert] = "msg"
                break
              end
              render :item
            end
            redirect_to :index
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before `break` in a block followed by `render`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            items.each do |item|
              if item.invalid?
                flash[:alert] = "msg"
                ^^^^^ Use `flash.now` before `render`.
                break
              end
            end
            render :index
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            items.each do |item|
              if item.invalid?
                flash.now[:alert] = "msg"
                break
              end
            end
            render :index
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before `break` in a loop' do
    it 'does not register an offense when `render` runs only before `flash` in the loop' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            while (item = queue.shift)
              if item.invalid?
                flash[:alert] = "msg"
                break
              end
              render :item
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a loop with unreachable `render`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            while (item = queue.shift)
              if item.valid?
                flash[:notice] = "msg"
                next
                render :edit
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before `next` in an `ensure` protected block' do
    it 'registers an offense when `render` is in the `ensure` branch' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            items.each do |item|
              begin
                flash[:notice] = "msg"
                ^^^^^ Use `flash.now` before `render`.
                next
              ensure
                render :item
              end
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            items.each do |item|
              begin
                flash.now[:notice] = "msg"
                next
              ensure
                render :item
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a loop' do
    it 'registers an offense when a later iteration can render' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            while (item = queue.shift)
              if item.valid?
                flash[:notice] = "msg"
                ^^^^^ Use `flash.now` before `render`.
              else
                render :edit
              end
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            while (item = queue.shift)
              if item.valid?
                flash.now[:notice] = "msg"
              else
                render :edit
              end
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when `respond_to` only renders in another format' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            while (item = queue.shift)
              respond_to do |format|
                format.html do
                  flash[:notice] = "msg"
                  log_event
                end
                format.json { render json: item }
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a block that runs once' do
    it 'does not register an offense when `render` is only in another branch' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            Post.transaction do
              if @post.save
                flash[:notice] = "msg"
              else
                render :new
                raise ActiveRecord::Rollback
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before `begin` with `render` only in `rescue`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            flash[:notice] = "msg"
            begin
              Notifier.deliver!(current_user)
            rescue Notifier::Error
              render :new
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before `begin` with `else`' do
    it 'does not register an offense when the `else` branch redirects before `render` after the `begin`' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            flash[:notice] = "msg"
            begin
              @post.save!
            rescue ActiveRecord::RecordInvalid
              log_error
            else
              redirect_to @post
              return
            end
            render :new
          end
        end
      RUBY
    end

    it 'does not register an offense when the body raises before `render` in the `else` branch' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            flash[:notice] = "msg"
            begin
              raise ActiveRecord::RecordInvalid
            rescue ActiveRecord::RecordInvalid
              redirect_to :index
            else
              render :new
            end
          end
        end
      RUBY
    end

    it 'registers an offense when the `else` branch renders' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            flash[:notice] = "msg"
            ^^^^^ Use `flash.now` before `render`.
            begin
              @post.save!
            rescue ActiveRecord::RecordInvalid
              redirect_to :index
            else
              render :new
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            flash.now[:notice] = "msg"
            begin
              @post.save!
            rescue ActiveRecord::RecordInvalid
              redirect_to :index
            else
              render :new
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a callback block' do
    it 'does not register an offense when `render` is only in a method defined after it' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          before_action do
            flash[:notice] = "msg"
            log_event
          end

          def show
            render :show
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a method followed by a class-level declaration' do
    it 'does not register an offense when `render` is only in the declaration' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            flash[:notice] = "msg"
            log_event
          end

          rescue_from ActiveRecord::RecordNotFound do
            render :not_found
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a `rescue` branch' do
    it 'does not register an offense when `render` is only in the `else` branch of the `rescue`' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              @user.save!
            rescue ActiveRecord::RecordInvalid
              flash[:alert] = "msg"
              log_event
            else
              render :new
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before `render` that precedes `redirect_to`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            flash[:notice] = "msg"
            ^^^^^ Use `flash.now` before `render`.
            render :new
            redirect_to :index
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            flash.now[:notice] = "msg"
            render :new
            redirect_to :index
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in an explicit `begin` followed by `render`' do
    it 'registers an offense when a statement follows `flash` within the `begin`' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              flash[:notice] = "msg"
              ^^^^^ Use `flash.now` before `render`.
              log_event
            ensure
              cleanup
            end
            render :new
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              flash.now[:notice] = "msg"
              log_event
            ensure
              cleanup
            end
            render :new
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a condition' do
    it 'registers an offense when `render` is in the branch' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if (flash[:notice] = message)
                ^^^^^ Use `flash.now` before `render`.
              render :new
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if (flash.now[:notice] = message)
              render :new
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in an iteration block followed by `redirect_to`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            items.each do |item|
              flash[:notice] = item.message
            end
            redirect_to :index
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a format block of `respond_to`' do
    it 'does not register an offense when `render` is only in another format block' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            respond_to do |format|
              format.html do
                flash[:warning] = "msg"
                redirect_to root_path unless request.path == root_path
              end
              format.json { render json: { success: false } }
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when `render` is only in another format block with a numbered parameter' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            respond_to do
              _1.html do
                flash[:warning] = "msg"
                redirect_to root_path unless request.path == root_path
              end
              _1.json { render json: { success: false } }
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when `render` is only in another format block with an `it` parameter',
       :ruby34, unsupported_on: :parser do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            respond_to do
              it.html do
                flash[:warning] = "msg"
                redirect_to root_path unless request.path == root_path
              end
              it.json { render json: { success: false } }
            end
          end
        end
      RUBY
    end

    it 'does not register an offense with a destructured block parameter' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            respond_to do |(format)|
              format.html do
                flash[:warning] = "msg"
                log_event
              end
            end
          end
        end
      RUBY
    end

    it 'registers an offense when `render` follows `flash` in the same format block' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            respond_to do |format|
              format.html do
                flash[:warning] = "msg"
                ^^^^^ Use `flash.now` before `render`.
                render :new
              end
              format.json { render json: { success: false } }
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            respond_to do |format|
              format.html do
                flash.now[:warning] = "msg"
                render :new
              end
              format.json { render json: { success: false } }
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` before format blocks of `respond_to`' do
    it 'does not register an offense when a format block redirects' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            respond_to do |format|
              if @post.save
                flash[:notice] = "msg"
                format.html { redirect_to(@post) }
                format.xml  { render xml: @post, status: :created }
              else
                format.html { render action: "new" }
                format.xml  { render xml: @post.errors, status: :unprocessable_entity }
              end
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when a later format block redirects' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @user.authenticated?
              flash[:notice] = "msg"
              respond_to do |format|
                format.json { render json: { location: root_path } }
                format.html { redirect_to root_path }
              end
            end
          end
        end
      RUBY
    end

    it 'registers an offense when no format block redirects' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            flash[:notice] = "msg"
            ^^^^^ Use `flash.now` before `render`.
            respond_to do |format|
              format.html { render :new }
              format.json { render json: { success: false } }
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            flash.now[:notice] = "msg"
            respond_to do |format|
              format.html { render :new }
              format.json { render json: { success: false } }
            end
          end
        end
      RUBY
    end
  end

  context 'when a whole file is a single `flash` assignment' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        flash[:notice] = "msg"
      RUBY
    end
  end

  context 'when using `flash` in a conditional used as a receiver' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @user
              flash[:notice] = "msg"
            end.then { log }
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

  context 'when using `flash` at the end of a block followed by a conditional `redirect_to`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            Post.transaction do
              flash[:notice] = "msg"
            end

            if @post.persisted?
              redirect_to @post
            else
              redirect_to :index
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` at the end of an action after `redirect_to`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            redirect_to :index
            flash[:notice] = "msg"
          end
        end
      RUBY
    end
  end

  context 'when using `flash` at the end of a callback block followed by a method with `redirect_to`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          before_action do
            flash[:notice] = "msg"
            ^^^^^ Use `flash.now` before `render`.
          end

          def create
            redirect_to :index
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          before_action do
            flash.now[:notice] = "msg"
          end

          def create
            redirect_to :index
          end
        end
      RUBY
    end
  end

  context 'when `flash` is used inside a block followed by method chaining' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class NonController < ApplicationRecord
          before_action do
            flash[:notice] = 'hello'
          end.do_something
        end
      RUBY
    end
  end

  context 'when using `flash` in a `case` branch' do
    it 'does not register an offense when `redirect_to` follows the `case`' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            unless @user
              case @context
              when Course
                flash[:error] = "msg"
              when Group
                flash[:error] = "msg"
              end
              redirect_to :index
              return
            end
            render :index
          end
        end
      RUBY
    end

    it 'registers an offense when `render` follows the `case`' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            case @context
            when Course
              flash[:error] = "msg"
              ^^^^^ Use `flash.now` before `render`.
            end
            render :index
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            case @context
            when Course
              flash.now[:error] = "msg"
            end
            render :index
          end
        end
      RUBY
    end

    it 'registers an offense when `render` follows `flash` in the same branch' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            case @context
            when Course
              flash[:error] = "msg"
              ^^^^^ Use `flash.now` before `render`.
              render :new
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            case @context
            when Course
              flash.now[:error] = "msg"
              render :new
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in an `if` branch' do
    it 'registers an offense when `render` follows `flash` in the same branch' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @user
              flash[:error] = "msg"
              ^^^^^ Use `flash.now` before `render`.
              render :new
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @user
              flash.now[:error] = "msg"
              render :new
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when `render` is only in the `else` branch' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @user.save
              flash[:notice] = "msg"
            else
              render :new
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when `render` is only in the `else` branch of an outer `if`' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @user
              if @user.save
                flash[:notice] = "msg"
              end
            else
              render :new
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when `render` is only in the `elsif` branch' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @user.save
              flash[:notice] = "msg"
            elsif @user.invalid?
              render :new
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a `begin` body' do
    it 'registers an offense when `render` follows `flash` in the same `begin` body' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              flash[:notice] = "msg"
              ^^^^^ Use `flash.now` before `render`.
              render :new
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              flash.now[:notice] = "msg"
              render :new
            end
          end
        end
      RUBY
    end

    it 'registers an offense when `render` is in the `else` branch that runs after the `begin` body' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              if @user.save
                flash[:notice] = "msg"
                ^^^^^ Use `flash.now` before `render`.
              end
            rescue StandardError
              log_error
            else
              render :new
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              if @user.save
                flash.now[:notice] = "msg"
              end
            rescue StandardError
              log_error
            else
              render :new
            end
          end
        end
      RUBY
    end

    it 'registers an offense when `flash` follows another statement and `render` is in the `else` branch' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              @user.save!
              flash[:notice] = "msg"
              ^^^^^ Use `flash.now` before `render`.
            rescue StandardError
              log_error
            else
              render :new
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              @user.save!
              flash.now[:notice] = "msg"
            rescue StandardError
              log_error
            else
              render :new
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when `render` is only in the `rescue` branch' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              flash[:notice] = "msg"
            rescue StandardError
              render :new
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when the `else` branch redirects before `render` after the `begin`' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              flash[:notice] = "msg"
              @post.save!
            rescue ActiveRecord::RecordInvalid
              log_error
            else
              log_event
              redirect_to @post
              return
            end
            render :new
          end
        end
      RUBY
    end

    it 'does not register an offense when the `else` branch returns before `render` after the `begin`' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            begin
              flash[:notice] = "msg"
              @post.save!
            rescue ActiveRecord::RecordInvalid
              log_error
            else
              log_event
              return
            end
            render :new
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a conditional followed by a block with `redirect_to ... and return` before `render`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            if @post.save
              flash[:notice] = "msg"
            end

            @post.with_lock do
              redirect_to @post and return
              render :new
            end
          end
        end
      RUBY
    end
  end

  context 'when using `flash` in a `case`-`in` branch' do
    it 'does not register an offense when `redirect_to` follows the `case`' do
      expect_no_offenses(<<~RUBY)
        class HomeController < ApplicationController
          def create
            unless @user
              case @context
              in Course
                flash[:error] = "msg"
              end
              redirect_to :index
              return
            end
            render :index
          end
        end
      RUBY
    end

    it 'registers an offense when `render` follows the `case`' do
      expect_offense(<<~RUBY)
        class HomeController < ApplicationController
          def create
            case @context
            in Course
              flash[:error] = "msg"
              ^^^^^ Use `flash.now` before `render`.
            end
            render :index
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class HomeController < ApplicationController
          def create
            case @context
            in Course
              flash.now[:error] = "msg"
            end
            render :index
          end
        end
      RUBY
    end
  end
end
