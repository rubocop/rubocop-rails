# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RenderInline do
  subject(:cop) { described_class.new }

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
end
