# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::UnsafeQueryCondition, :config do
  let(:cop_config) { { 'EnforcedStyle' => 'params' } }

  it 'does not register an offense when using a condition method safely' do
    RuboCop::Cop::Rails::UnsafeQueryCondition::RESTRICT_ON_SEND.each do |meth|
      expect_no_offenses("Model.#{meth}(:literal)")
    end
  end

  it 'registers an offense when using a condition method unsafely' do
    RuboCop::Cop::Rails::UnsafeQueryCondition::RESTRICT_ON_SEND.each do |method|
      expect_offense(<<~RUBY, method: method)
        Model.#{method}("\#{interpolation}")
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^ Avoid using non-literal keys in ActiveRecord conditions.
      RUBY
    end
  end

  it 'registers an offense when using string interpolation in a condition' do
    expect_offense(<<~'RUBY')
      where("created_at > #{unsafe}")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using non-literal keys in ActiveRecord conditions.
    RUBY
  end

  it 'does not register an offense when using multi-line literal strings' do
    # From a parsing perspective, this looks similar to string interpolation
    # so make sure we don't mark it as a false positive.
    expect_no_offenses(<<~RUBY)
      where(
        'part of a literal string'\
        'more literal string'
      )
    RUBY
  end

  it 'registers an offense when using `params` as a condition' do
    expect_offense(<<~RUBY)
      find_by(params[:id])
      ^^^^^^^^^^^^^^^^^^^^ Avoid using non-literal keys in ActiveRecord conditions.
    RUBY
  end

  it 'does not register an offense when using another method as a condition' do
    expect_no_offenses('find_by(anything_else[:id])')
  end

  context 'with style: all' do
    let(:cop_config) { { 'EnforcedStyle' => 'all' } }

    it 'registers an offense when using any method as a condition' do
      expect_offense(<<~RUBY)
        find_by(anthing_else[:id])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using non-literal keys in ActiveRecord conditions.
      RUBY
    end
  end
end
