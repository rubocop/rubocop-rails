# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ReflectionClassName, :config do
  context "registers an offense when using `foreign_key: 'account_id'`" do
    it 'has_many' do
      expect_offense(<<~RUBY)
        has_many :accounts, class_name: Account, foreign_key: :account_id
                            ^^^^^^^^^^^^^^^^^^^ Use a string value for `class_name`.
      RUBY

      expect_correction(<<~RUBY)
        has_many :accounts, class_name: "Account", foreign_key: :account_id
      RUBY
    end

    it '.name' do
      expect_offense(<<~RUBY)
        has_many :accounts, class_name: Account.name
                            ^^^^^^^^^^^^^^^^^^^^^^^^ Use a string value for `class_name`.
      RUBY

      expect_correction(<<~RUBY)
        has_many :accounts, class_name: "Account"
      RUBY
    end

    it '.to_s' do
      expect_offense(<<~RUBY)
        has_many :accounts, class_name: Account.to_s
                            ^^^^^^^^^^^^^^^^^^^^^^^^ Use a string value for `class_name`.
      RUBY

      expect_correction(<<~RUBY)
        has_many :accounts, class_name: "Account"
      RUBY
    end

    it 'has_one' do
      expect_offense(<<~RUBY)
        has_one :account, class_name: Account
                          ^^^^^^^^^^^^^^^^^^^ Use a string value for `class_name`.
      RUBY

      expect_correction(<<~RUBY)
        has_one :account, class_name: "Account"
      RUBY
    end

    it 'belongs_to' do
      expect_offense(<<~RUBY)
        belongs_to :account, class_name: Account
                             ^^^^^^^^^^^^^^^^^^^ Use a string value for `class_name`.
      RUBY

      expect_correction(<<~RUBY)
        belongs_to :account, class_name: "Account"
      RUBY
    end
  end

  context 'when a relation has a scope parameter' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        belongs_to :account, -> { distinct }, class_name: Account
                                              ^^^^^^^^^^^^^^^^^^^ Use a string value for `class_name`.
      RUBY
    end
  end

  it 'does not register an offense when using string with interpolation' do
    expect_no_offenses(<<~'RUBY')
      has_many :accounts, class_name: "#{prefix}Account"
    RUBY
  end

  it 'does not register an offense when using `class_name: do_something.to_s`' do
    expect_no_offenses(<<~RUBY)
      has_many :accounts, class_name: do_something.to_s
    RUBY
  end

  it 'does not register an offense when using `class_name: to_s`' do
    expect_no_offenses(<<~RUBY)
      has_many :accounts, class_name: to_s
    RUBY
  end

  it 'does not register an offense when using `foreign_key :account_id`' do
    expect_no_offenses(<<~RUBY)
      has_many :accounts, class_name: 'Account', foreign_key: :account_id
      has_one :account, class_name: 'Account'
      belongs_to :account, class_name: 'Account'
    RUBY
  end

  it 'does not register an offense when using symbol for `class_name`' do
    expect_no_offenses(<<~RUBY)
      has_many :accounts, class_name: :Account, foreign_key: :account_id
      has_one :account, class_name: :Account
      belongs_to :account, class_name: :Account
    RUBY
  end

  it 'registers an offense when parameter value is a local variable assigned a constant' do
    expect_offense(<<~RUBY)
      class_name = Account

      has_many :accounts, class_name: class_name
                          ^^^^^^^^^^^^^^^^^^^^^^ Use a string value for `class_name`.
    RUBY
  end

  it 'does not register an offense when parameter value is a local variable assigned a string' do
    expect_no_offenses(<<~RUBY)
      class_name = 'Account'

      has_many :accounts, class_name: class_name
    RUBY
  end

  it 'does not register an offense when parameter value is a method call' do
    expect_no_offenses(<<~RUBY)
      has_many :accounts, class_name: class_name
    RUBY
  end

  it 'does not register an offense when parameter value is a method call on an object in a variable' do
    expect_no_offenses(<<~RUBY)
      has_many :accounts, class_name: some_thing.class_name
    RUBY
  end

  context 'Ruby >= 3.1', :ruby31 do
    it 'registers an offense when shorthand syntax value is a local variable assigned a constant' do
      expect_offense(<<~RUBY)
        class_name = Account

        has_many :accounts, class_name:
                            ^^^^^^^^^^^ Use a string value for `class_name`.
      RUBY
    end

    it 'does not register an offense when shorthand syntax value is a local variable assigned a string' do
      expect_no_offenses(<<~RUBY)
        class_name = 'Account'

        has_many :accounts, class_name:
      RUBY
    end

    it 'does not register an offense when shorthand syntax value is a local variable assigned a method call' do
      expect_no_offenses(<<~RUBY)
        has_many :accounts, class_name:
      RUBY
    end
  end
end
