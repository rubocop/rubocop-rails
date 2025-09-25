# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TransactionExitStatement, :config do
  shared_examples 'flags transaction exit statements' do |method|
    it 'registers an offense when `return` is used in transactions' do
      expect_offense(<<~RUBY, method: method)
        ApplicationRecord.%{method} do
          return if user.active?
          ^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
        end
      RUBY
    end

    it 'registers an offense when `return` is used in transaction with numblock' do
      expect_offense(<<~RUBY, method: method)
        ApplicationRecord.%{method} do
          _1.after_commit { }
          return if user.active?
          ^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
        end
      RUBY
    end

    it 'registers an offense when `return` is used in transaction with itblock', :ruby34, unsupported_on: :parser do
      expect_offense(<<~RUBY, method: method)
        ApplicationRecord.%{method} do
          it.after_commit { }
          return if user.active?
          ^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
        end
      RUBY
    end

    it 'registers an offense when `break` is used in transactions' do
      expect_offense(<<~RUBY, method: method)
        ApplicationRecord.%{method} do
          break if user.active?
          ^^^^^ Exit statement `break` is not allowed. Use `raise` (rollback) or `next` (commit).
        end
      RUBY
    end

    it 'registers an offense when `throw` is used in transactions' do
      expect_offense(<<~RUBY, method: method)
        ApplicationRecord.%{method} do
          throw if user.active?
          ^^^^^ Exit statement `throw` is not allowed. Use `raise` (rollback) or `next` (commit).
        end
      RUBY
    end

    it 'does not register an offense when `next` is used in transactions' do
      expect_no_offenses(<<~RUBY)
        ApplicationRecord.#{method} do
          next if user.active?
        end
      RUBY
    end

    it 'does not register an offense when `raise` is used in transactions' do
      expect_no_offenses(<<~RUBY)
        ApplicationRecord.#{method} do
          raise if user.active?
        end
      RUBY
    end

    it 'registers an offense when `return` is used in `loop` in transactions' do
      expect_offense(<<~RUBY, method: method)
        ApplicationRecord.%{method} do
          loop do
            return if condition
            ^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
          end
        end
      RUBY
    end

    it 'registers an offense when `return` is used in `each` with numblock in transactions' do
      expect_offense(<<~RUBY, method: method)
        ApplicationRecord.%{method} do
          foo.each do
            return if _1
            ^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
          end
        end
      RUBY
    end

    it 'registers an offense when `return` is used in `each` with itblock in transactions', :ruby34,
       unsupported_on: :parser do
      expect_offense(<<~RUBY, method: method)
        ApplicationRecord.%{method} do
          foo.each do
            return if it
            ^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
          end
        end
      RUBY
    end

    it 'registers an offense when `throw` is used in `loop` in transactions' do
      expect_offense(<<~RUBY, method: method)
        ApplicationRecord.%{method} do
          loop do
            throw if condition
            ^^^^^ Exit statement `throw` is not allowed. Use `raise` (rollback) or `next` (commit).
          end
        end
      RUBY
    end

    it 'does not register an offense when `break` is used in `loop` in transactions' do
      expect_no_offenses(<<~RUBY)
        ApplicationRecord.#{method} do
          loop do
            break if condition
          end
        end
      RUBY
    end

    it 'does not register an offense when `break` is used in `while` in transactions' do
      expect_no_offenses(<<~RUBY)
        ApplicationRecord.#{method} do
          while proceed_looping? do
            break if condition
          end
        end
      RUBY
    end

    it 'does not register an offense when `break` is used in `until` in transactions' do
      expect_no_offenses(<<~RUBY)
        ApplicationRecord.#{method} do
          until stop_looping? do
            break if condition
          end
        end
      RUBY
    end

    it 'does not register an offense when `break` is used in `each` with numblock in transactions' do
      expect_no_offenses(<<~RUBY)
        ApplicationRecord.#{method} do
          foo.each do
            break if _1
          end
        end
      RUBY
    end

    context 'when using Ruby >= 3.4', :ruby34, unsupported_on: :parser do
      it 'does not register an offense when `break` is used in `each` with itblock in transactions' do
        expect_no_offenses(<<~RUBY)
          ApplicationRecord.#{method} do
            foo.each do
              break if it
            end
          end
        RUBY
      end
    end

    it 'registers an offense when `return` is used in `rescue`' do
      expect_offense(<<~RUBY, method: method)
        ApplicationRecord.%{method} do
        rescue
          return do_something
          ^^^^^^^^^^^^^^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
        end
      RUBY
    end

    it 'registers an offense when `return` is used outside of a `rescue`' do
      expect_offense(<<~RUBY, method: method)
        ApplicationRecord.%{method} do
          return if user.active?
          ^^^^^^ Exit statement `return` is not allowed. Use `raise` (rollback) or `next` (commit).
        rescue
          pass
        end
      RUBY
    end

    it 'does not register an offense when transaction block is empty' do
      expect_no_offenses(<<~RUBY)
        ApplicationRecord.#{method} do
        end
      RUBY
    end

    it 'does not register an offense when a method call is chained' do
      expect_no_offenses(<<~RUBY)
        #{method}.foo
      RUBY
    end

    it 'does not register an offense when no receiver and no block' do
      expect_no_offenses(<<~RUBY)
        #{method}
      RUBY
    end
  end

  it_behaves_like 'flags transaction exit statements', :transaction
  it_behaves_like 'flags transaction exit statements', :with_lock

  context 'when `TransactionMethods: [writable_transaction]`' do
    let(:cop_config) { { 'TransactionMethods' => %w[writable_transaction] } }

    it_behaves_like 'flags transaction exit statements', :writable_transaction
  end

  context 'Rails >= 7.2', :rails72 do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        ApplicationRecord.transaction do
          return if user.active?
        end
      RUBY
    end

    context 'when EnableForAllRailsVersions is true' do
      let(:cop_config) { { 'EnableForAllRailsVersions' => true } }
      it_behaves_like 'flags transaction exit statements', :transaction
      it_behaves_like 'flags transaction exit statements', :with_lock
      context 'when `TransactionMethods: [writable_transaction]`' do
        let(:cop_config) { super().merge({ 'TransactionMethods' => %w[writable_transaction] }) }
        it_behaves_like 'flags transaction exit statements', :writable_transaction
      end
    end
  end
end
