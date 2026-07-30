# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ValidationsGrouping, :config do
  let(:cop_config) { { 'SingleAttributeValidations' => false } }

  it 'registers an offense when attribute validations are split' do
    expect_offense(<<~RUBY)
      validates :name, :email, presence: true
                       ^^^^^^ Group together all email validations.
      validates :email, format: { with: /@/ }
                ^^^^^^ Group together all email validations.
    RUBY
  end

  it 'does not register an offense when attribute validations are grouped' do
    expect_no_offenses(<<~RUBY)
      validates :email, presence: true, format: { with: /@/ }
    RUBY
  end

  it 'does not register an offense for not-literal attribute name validations' do
    expect_no_offenses(<<~RUBY)
      validates attribute, presence: true
      validates attribute, format: { with: /@/ }
    RUBY
  end

  it 'does not register an offense when attribute validations have different configuration options' do
    expect_no_offenses(<<~RUBY)
      validates :email, presence: true, if: :some_condition?
      validates :email, format: { with: /@/ }
    RUBY
  end

  it 'registers an offense when attribute validations have same configuration options' do
    expect_offense(<<~RUBY)
      validates :email, presence: true, if: :some_condition?
                ^^^^^^ Group together all email validations.
      validates :email, format: { with: /@/ }, if: :some_condition?
                ^^^^^^ Group together all email validations.
    RUBY
  end

  it 'registers an offense when attribute validations have different validation options' do
    expect_offense(<<~RUBY)
      validates :email, format: { with: /foo/ }
                ^^^^^^ Group together all email validations.
      validates :email, format: { with: /bar/ }
                ^^^^^^ Group together all email validations.
    RUBY
  end

  context 'with conditionals' do
    it 'registers an offense when attribute validations within conditional are split' do
      expect_offense(<<~RUBY)
        validates :email, uniqueness: true

        if condition?
          validates :name, :email, presence: true
                           ^^^^^^ Group together all email validations.
          validates :email, format: { with: /@/ }
                    ^^^^^^ Group together all email validations.
        end
      RUBY
    end

    it 'registers an offense when attribute validations outside conditional are split' do
      expect_offense(<<~RUBY)
        validates :name, :email, presence: true
                         ^^^^^^ Group together all email validations.
        validates :email, format: { with: /@/ }
                  ^^^^^^ Group together all email validations.

        if condition?
          validates :email, uniqueness: true
        end
      RUBY
    end
  end

  context 'SingleAttributeValidations is used' do
    let(:cop_config) { { 'SingleAttributeValidations' => true } }

    it 'registers and offense for multiple attributes per validation' do
      expect_offense(<<~RUBY)
        validates :name, :email, presence: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify single attribute per validation.
        validates :name, :email, presence: true, if: :some_condition?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify single attribute per validation.
      RUBY
    end
  end
end
