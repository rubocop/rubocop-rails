# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DoubleRender do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  describe '#DoubleRenderError' do
    it 'registers offenses with multiple reachable render method' do
      expect_offense(<<~RUBY)
        def show
            redirect_to :show
            ^^^^^^^^^^^ AbstractController::DoubleRenderError may occur.

           render :edit
           ^^^^^^ AbstractController::DoubleRenderError may occur.
         end
      RUBY
    end

    it 'dont registers an offense with single reachable render method' do
      expect_no_offenses(<<~RUBY)
        def show
           something

           render :edit
         end
      RUBY
    end

    context 'with if statement' do
      it 'registers offenses with multiple reachable render method' do
        expect_offense(<<~RUBY)
          def show
             if cond?
                redirect_to :index
                ^^^^^^^^^^^ AbstractController::DoubleRenderError may occur.
              else
                render :show
                ^^^^^^ AbstractController::DoubleRenderError may occur.
             end

             render :edit
             ^^^^^^ AbstractController::DoubleRenderError may occur.
           end
        RUBY
      end

      it 'dont registers an offense with single reachable render method' do
        expect_no_offenses(<<~RUBY)
          def show
             if cond?
                redirect_to :index
              elsif
                render :show
              else
                render :edit
             end
           end
        RUBY
      end

      it 'registers offenses with modify if statement' do
        expect_offense(<<~RUBY)
          def show
             redirect_to :index if cond?
             ^^^^^^^^^^^ AbstractController::DoubleRenderError may occur.

             render :edit
             ^^^^^^ AbstractController::DoubleRenderError may occur.
          end
        RUBY
      end
    end

    context 'with case statement' do
      it 'registers offenses with multiple reachable render method' do
        expect_offense(<<~RUBY)
          def show
            case some
            when cond?
              redirect_to :index
              ^^^^^^^^^^^ AbstractController::DoubleRenderError may occur.
            when cond?
              redirect_to :show
              ^^^^^^^^^^^ AbstractController::DoubleRenderError may occur.
            end

            redirect_to :edit
            ^^^^^^^^^^^ AbstractController::DoubleRenderError may occur.
          end
        RUBY
      end

      it 'dont registers an offense with single reachable render method' do
        expect_no_offenses(<<~RUBY)
          def show
            case some
            when cond?
              redirect_to :index
            when cond?
              redirect_to :show
            else cond?
              redirect_to :edit
            end
          end
        RUBY
      end
    end

    context 'with ensure' do
      it ' registers offenses with multiple reachable render method' do
        expect_offense(<<~RUBY)
          def show
            redirect_to :index
            ^^^^^^^^^^^ AbstractController::DoubleRenderError may occur.
          ensure
            redirect_to :show
            ^^^^^^^^^^^ AbstractController::DoubleRenderError may occur.
          end
        RUBY
      end
    end
  end
end
