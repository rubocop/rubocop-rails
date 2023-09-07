# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::UnusedRenderContent, :config do
  it 'does not register an offense when specifying body content with a status that takes a body' do
    expect_no_offenses(<<~RUBY)
      render status: :ok, plain: 'Ruby!'
    RUBY
  end

  it 'does not register an offense when no body content is specified with a status that does not take a body' do
    expect_no_offenses(<<~RUBY)
      render status: :no_content
    RUBY
  end

  it 'registers an offense when specifying status: :continue and a positional string argument' do
    expect_offense(<<~RUBY)
      render 'foo', status: :continue
             ^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: :switching_protocols and a positional symbol argument across ' \
     'multiple lines' do
    expect_offense(<<~RUBY)
      render(
        :foo,
        ^^^^ Do not specify body content for a response with a non-content status code
        status: :switching_protocols
      )
    RUBY
  end

  it 'registers an offense when specifying status: :processing and an :action option as the last argument' do
    expect_offense(<<~RUBY)
      render status: :processing, action: :foo
                                  ^^^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: :early_hints and a :body option as the first argument' do
    expect_offense(<<~RUBY)
      render body: 'foo', status: :early_hints
             ^^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: :no_content and a :content_type option between other options' do
    expect_offense(<<~RUBY)
      render status: :no_content, content_type: 'foo', another: 'option'
                                  ^^^^^^^^^^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: :reset_content and a :file option' do
    expect_offense(<<~RUBY)
      render status: :reset_content, file: 'foo'
                                     ^^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: :not_modified and a :html option' do
    expect_offense(<<~RUBY)
      render status: :not_modified, html: 'foo'
                                    ^^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: 100 and a :inline option' do
    expect_offense(<<~RUBY)
      render status: 100, inline: 'foo'
                          ^^^^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: 101 and a :json option' do
    expect_offense(<<~RUBY)
      render status: 101, json: 'foo'
                          ^^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: 102 and a :js option' do
    expect_offense(<<~RUBY)
      render status: 102, js: 'foo'
                          ^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: 103 and a :layout option' do
    expect_offense(<<~RUBY)
      render status: 103, layout: 'foo'
                          ^^^^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: 204 and a :plain option' do
    expect_offense(<<~RUBY)
      render status: 204, plain: 'foo'
                          ^^^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: 205 and a :raw option' do
    expect_offense(<<~RUBY)
      render status: 205, raw: 'foo'
                          ^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: 304 and a :template option' do
    expect_offense(<<~RUBY)
      render status: 304, template: 'foo'
                          ^^^^^^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: 304 and a :text option' do
    expect_offense(<<~RUBY)
      render status: 304, text: 'foo'
                          ^^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end

  it 'registers an offense when specifying status: 304 and a :xml option' do
    expect_offense(<<~RUBY)
      render status: 304, xml: 'foo'
                          ^^^^^^^^^^ Do not specify body content for a response with a non-content status code
    RUBY
  end
end
