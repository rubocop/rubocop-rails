# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::IgnoredSkipActionFilterOption, :config do
  it 'registers an offense when `if` and `only` are used together' do
    expect_offense(<<~RUBY)
      skip_before_action :login_required, only: :show, if: :trusted_origin?
                                                       ^^^^^^^^^^^^^^^^^^^^ `if` option will be ignored when `only` and `if` are used together.
    RUBY

    expect_correction(<<~RUBY)
      skip_before_action :login_required, only: :show
    RUBY
  end

  it 'registers an offense when `if` and `except` are used together' do
    expect_offense(<<~RUBY)
      skip_before_action :login_required, except: :admin, if: :trusted_origin?
                                          ^^^^^^^^^^^^^^ `except` option will be ignored when `if` and `except` are used together.
    RUBY

    expect_correction(<<~RUBY)
      skip_before_action :login_required, if: :trusted_origin?
    RUBY
  end

  it 'does not register an offense when `if` is used only' do
    expect_no_offenses(<<~RUBY)
      skip_before_action :login_required, if: -> { trusted_origin? && action_name == "show" }
    RUBY
  end
end
