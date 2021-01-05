# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TransactionRequiresNew do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when no arguments are passed' do
    it 'registers an offense when using `ActiveRecord::Base#transaction`' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.transaction do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Always pass "requires_new: true" to transactions.
        end
      RUBY

      expect_correction(<<~RUBY)
        ActiveRecord::Base.transaction(requires_new: true) do
        end
      RUBY
    end

    it 'registers an offense when using a Model transaction' do
      expect_offense(<<~RUBY)
        User.transaction do
        ^^^^^^^^^^^^^^^^^^^ Always pass "requires_new: true" to transactions.
        end
      RUBY

      expect_correction(<<~RUBY)
        User.transaction(requires_new: true) do
        end
      RUBY
    end
  end

  context 'when arguments other than `requires_new: true` are passsed' do
    it 'registers an offense when using `ActiveRecord::Base#transaction`' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.transaction(some_option: false) do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Always pass "requires_new: true" to transactions.
        end
      RUBY

      # Does NOT auto-correct when arugments are present
      expect_correction(<<~RUBY)
        ActiveRecord::Base.transaction(some_option: false) do
        end
      RUBY
    end

    it 'registers an offense when using a Model transaction' do
      expect_offense(<<~RUBY)
        User.transaction(some_option: true) do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Always pass "requires_new: true" to transactions.
        end
      RUBY

      # does NOT auto-correct when arguments are present
      expect_correction(<<~RUBY)
        User.transaction(some_option: true) do
        end
      RUBY
    end
  end

  context 'when `requires_new: true` is passed' do
    it 'does not register an offense when using `ActiveRecord::Base#transaction`' do
      expect_no_offenses(<<~RUBY)
        ActiveRecord::Base.transaction(requires_new: true) do
        end
      RUBY
    end

    it 'does not register an offense when using a Model transaction' do
      expect_no_offenses(<<~RUBY)
        User.transaction(requires_new: true) do
        end
      RUBY
    end
  end
end
