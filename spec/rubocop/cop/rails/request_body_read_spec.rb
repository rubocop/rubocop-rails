# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RequestBodyRead, :config do
  it 'adds offense when using `request.body.read`' do
    expect_offense(<<~RUBY)
      request.body.read
      ^^^^^^^^^^^^^^^^^ Use `request.raw_post` instead.
    RUBY

    expect_correction(<<~RUBY)
      request.raw_post
    RUBY
  end

  it 'does not add offense when doing a partial read`' do
    expect_no_offenses(<<~RUBY)
      request.body.read(16.kilobytes)
    RUBY
  end
end
