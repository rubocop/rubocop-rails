# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::CallbackOptionsUniqueness, :config do
  context 'with duplicate values' do
    context 'with before_action only' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          before_action :my_method, only: [:index, :index, :show]
                                                  ^^^^^^ Duplicate value `:index` found in `only` option of `before_action` callback.
        RUBY
      end
    end

    context 'with before_action except option' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          before_action :dummy_method, except: [:create, :destroy, :destroy]
                                                                    ^^^^^^^^ Duplicate value `:destroy` found in `except` option of `before_action` callback.
        RUBY
      end
    end

    context 'with prepend_after_action only option' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          prepend_after_action :dummy_method, only: [:create, :destroy, :destroy]
                                                                        ^^^^^^^^ Duplicate value `:destroy` found in `only` option of `prepend_after_action` callback.
        RUBY
      end
    end

    context 'with all possible callback types' do
      (RuboCop::Cop::Rails::ActionFilter::FILTER_METHODS + RuboCop::Cop::Rails::ActionFilter::ACTION_METHODS).each do |callback_name|
        it "registers an offense for `#{callback_name}` callback" do
          offenses = inspect_source("#{callback_name} :meth, only: %i[a1 a2 a2]")
          expect(offenses.size).to eq(1)
        end
      end
    end

    context 'with callback config using shorthand symbol array syntax' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          before_action :my_method, only: %i[index index show]
                                                   ^^^^^ Duplicate value `index` found in `only` option of `before_action` callback.
        RUBY
      end
    end

    context 'with callback config specified over multiple lines' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          before_action :my_method,
                        only: %i[
                          index
                          index
                          ^^^^^ Duplicate value `index` found in `only` option of `before_action` callback.
                          show
                        ]
        RUBY
      end
    end
  end

  context 'with no options' do
    it 'registers no offense when no options are used at all' do
      expect_no_offenses('before_action :my_method')
    end
  end

  context 'with options other than except or only' do
    it 'registers no offense when except/only are not used' do
      expect_no_offenses('before_action :my_method, if: -> { true }')
    end
  end

  context 'with several duplicated values' do
    it 'registers multiple offenses' do
      expect_offense(<<~RUBY)
        before_action :my_method, only: %i[index index index show]
                                                 ^^^^^ Duplicate value `index` found in `only` config of `before_action` callback.
                                                       ^^^^^ Duplicate value `index` found in `only` config of `before_action` callback.
      RUBY
    end
  end
end
