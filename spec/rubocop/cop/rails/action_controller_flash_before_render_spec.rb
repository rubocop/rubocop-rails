# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActionControllerFlashBeforeRender, :config do
  context 'when using `flash` before `render`' do
    context 'within an instance method' do
      %w[ActionController::Base ApplicationController].each do |parent_class|
        context "within a class inherited from #{parent_class}" do
          it 'registers an offense and corrects' do
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
end
