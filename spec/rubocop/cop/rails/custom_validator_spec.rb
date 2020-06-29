# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::CustomValidator do
  subject(:cop) { described_class.new }

  it 'registers an offense when using `format` validation with regex as value' do
    expect_offense(<<~RUBY)
      validates :email, format: /@/
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider extracting custom validator.
    RUBY
  end

  it 'registers an offense when using `format` validation with hash as value' do
    expect_offense(<<~RUBY)
      validates :email, format: { with: /@/ }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider extracting custom validator.
    RUBY
  end

  it 'registers an offense when using `format` validation with multiple attributes' do
    expect_offense(<<~RUBY)
      validates :email, :name, format: { with: /@/ }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider extracting custom validator.
    RUBY
  end

  it 'does not register an offense when using validation other than `format`' do
    expect_no_offenses(<<~RUBY)
      validates :email, presence: true
    RUBY
  end
end
