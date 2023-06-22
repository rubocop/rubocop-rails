# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::AcceptsNestedAttributesForUpdateOnly, :config do
  context 'accepts_nested_attributes_for' do
    it 'registers an offense when not specifying any options' do
      expect_offense(<<~RUBY)
        class Member < ApplicationRecord
          has_one :avatar
          accepts_nested_attributes_for :avatar
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify a `:update_only` option.
        end
      RUBY
    end

    it 'registers an offense when missing an explicit `:update_only` flag' do
      expect_offense(<<~RUBY)
        class Member < ApplicationRecord
          has_one :avatar
          accepts_nested_attributes_for :avatar, reject_if: :all_blank
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify a `:update_only` option.
        end
      RUBY
    end

    it 'does not register an offense when specifying `:update_only` flag' do
      expect_no_offenses(<<~RUBY)
        class Member < ApplicationRecord
          has_one :avatar
          accepts_nested_attributes_for :avatar, update_only: true
        end
      RUBY
    end

    it 'does not register an offense when specifying `:update_only` flag with double splat' do
      expect_no_offenses(<<~RUBY)
        class Member < ApplicationRecord
          has_one :avatar
          accepts_nested_attributes_for :avatar, **{update_only: true}
        end
      RUBY
    end

    it 'registers an offense when a variable passed with double splat' do
      expect_offense(<<~RUBY)
        class Member < ApplicationRecord
          has_one :avatar
          accepts_nested_attributes_for :avatar, **bar
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify a `:update_only` option.
        end
      RUBY
    end

    context 'with_options update_only: true' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class Member < ApplicationRecord
            has_one :avatar
            with_options update_only: true do
              accepts_nested_attributes_for :avatar
            end
          end
        RUBY
      end

      it 'does not register an offense for using `reject_if` option' do
        expect_no_offenses(<<~RUBY)
          class Member < ApplicationRecord
            has_one :avatar
            with_options update_only: true do
              accepts_nested_attributes_for :avatar, reject_if: :all_blank
            end
          end
        RUBY
      end
    end
  end

  context 'when an Active Record model does not have any associations' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Member < ApplicationRecord
        end
      RUBY
    end
  end
end
