# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RedundantReceiverInWithOptions, :config do
  it 'registers an offense and corrects using explicit receiver in `with_options`' do
    expect_offense(<<~RUBY)
      class Account < ApplicationRecord
        with_options dependent: :destroy do |assoc|
          assoc.has_many :customers
          ^^^^^ Redundant receiver in `with_options`.
          assoc.has_many :products
          ^^^^^ Redundant receiver in `with_options`.
          assoc.has_many :invoices
          ^^^^^ Redundant receiver in `with_options`.
          assoc.has_many :expenses
          ^^^^^ Redundant receiver in `with_options`.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Account < ApplicationRecord
        with_options dependent: :destroy do
          has_many :customers
          has_many :products
          has_many :invoices
          has_many :expenses
        end
      end
    RUBY
  end

  context 'Ruby >= 2.7', :ruby27 do
    it 'registers an offense and corrects using explicit receiver in `with_options`' do
      expect_offense(<<~RUBY)
        class Account < ApplicationRecord
          with_options dependent: :destroy do
            _1.has_many :customers
            ^^ Redundant receiver in `with_options`.
            _1.has_many :products
            ^^ Redundant receiver in `with_options`.
            _1.has_many :invoices
            ^^ Redundant receiver in `with_options`.
            _1.has_many :expenses
            ^^ Redundant receiver in `with_options`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Account < ApplicationRecord
          with_options dependent: :destroy do
            has_many :customers
            has_many :products
            has_many :invoices
            has_many :expenses
          end
        end
      RUBY
    end
  end

  context 'Ruby >= 3.4', :ruby34, unsupported_on: :parser do
    it 'registers an offense and corrects using explicit receiver in `with_options`' do
      expect_offense(<<~RUBY)
        class Account < ApplicationRecord
          with_options dependent: :destroy do
            it.has_many :customers
            ^^ Redundant receiver in `with_options`.
            it.has_many :products
            ^^ Redundant receiver in `with_options`.
            it.has_many :invoices
            ^^ Redundant receiver in `with_options`.
            it.has_many :expenses
            ^^ Redundant receiver in `with_options`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Account < ApplicationRecord
          with_options dependent: :destroy do
            has_many :customers
            has_many :products
            has_many :invoices
            has_many :expenses
          end
        end
      RUBY
    end
  end

  it 'does not register an offense when using implicit receiver in `with_options`' do
    expect_no_offenses(<<~RUBY)
      class Account < ApplicationRecord
        with_options dependent: :destroy do
          has_many :customers
          has_many :products
          has_many :invoices
          has_many :expenses
        end
      end
    RUBY
  end

  it 'registers an offense and corrects when including multiple redundant receivers in single line' do
    expect_offense(<<~RUBY)
      with_options options: false do |merger|
        merger.invoke(merger.something)
        ^^^^^^ Redundant receiver in `with_options`.
                      ^^^^^^ Redundant receiver in `with_options`.
      end
    RUBY

    expect_correction(<<~RUBY)
      with_options options: false do
        invoke(something)
      end
    RUBY
  end

  it 'does not register an offense when including method invocations to different receivers' do
    expect_no_offenses(<<~RUBY)
      client = ApplicationClient.new
      with_options options: false do |merger|
        client.invoke(merger.something, something)
      end
    RUBY
  end

  it 'does not register an offense when including block node in `with_options`' do
    expect_no_offenses(<<~RUBY)
      with_options options: false do |merger|
        merger.invoke
        with_another_method do |another_receiver|
          merger.invoke(another_receiver)
        end
      end
    RUBY
  end

  it 'does not register an offense when calling a method with a receiver in `with_options` without block arguments' do
    expect_no_offenses(<<~RUBY)
      with_options do
        obj.do_something
      end
    RUBY
  end

  it 'does not register an offense when empty' do
    expect_no_offenses(<<~RUBY)
      with_options options: false do |merger|
      end
    RUBY
  end
end
