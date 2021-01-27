# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RenderInline, :config do
  it 'registers an offense when rendering inline with a symbol key' do
    expect_offense(<<~RUBY)
      render status: 200, inline: 'inline template'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using a template over inline rendering.
    RUBY
  end

  it 'registers an offense when rendering inline with a string key' do
    expect_offense(<<~RUBY)
      render status: 200, 'inline' => 'inline template'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using a template over inline rendering.
    RUBY
  end

  it 'does not register an offense when rendering a template' do
    expect_no_offenses(<<~RUBY)
      render :index
    RUBY
  end

  it 'does not register an offense when passing other options to render' do
    expect_no_offenses(<<~RUBY)
      render json: users, serializer: UserSerializer
    RUBY
  end

  it 'does not register an offense when passing other options where key is a variable' do
    expect_no_offenses(<<~RUBY)
      serializer = users.respond_to?(:each) ? :each_serializer : :serializer
      render json: users, serializer => UserSerializer
    RUBY
  end
end
