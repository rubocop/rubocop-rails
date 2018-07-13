# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::FindBy do
  subject(:cop) { described_class.new }

  it 'registers an offense when using `#first`' do
    expect_offense(<<-RUBY.strip_indent)
      User.where(id: x).first
           ^^^^^^^^^^^^^^^^^^ Use `find_by` instead of `where.first`.
    RUBY
  end

  it 'registers an offense when using `#take`' do
    expect_offense(<<-RUBY.strip_indent)
      User.where(id: x).take
           ^^^^^^^^^^^^^^^^^ Use `find_by` instead of `where.take`.
    RUBY
  end

  it 'does not register an offense when using find_by' do
    expect_no_offenses('User.find_by(id: x)')
  end

  it 'autocorrects where.take to find_by' do
    new_source = autocorrect_source('User.where(id: x).take')

    expect(new_source).to eq('User.find_by(id: x)')
  end

  it 'does not autocorrect where.first' do
    new_source = autocorrect_source('User.where(id: x).first')

    expect(new_source).to eq('User.where(id: x).first')
  end
end
