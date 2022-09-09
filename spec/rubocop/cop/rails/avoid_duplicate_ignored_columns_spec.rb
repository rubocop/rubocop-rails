# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::AvoidDuplicateIgnoredColumns, :config do
  context 'with no duplicate `self.ignored_columns=` call' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          self.ignored_columns = %w(profile birthday)
        end
      RUBY
    end
  end

  context 'with duplicate `self.ignored_columns=` call' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class User < ApplicationRecord
          self.ignored_columns = %w(profile)
          self.ignored_columns = %w(birthday)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `self.ignored_columns=` has already been called on line 2.
        end
      RUBY
    end
  end
end
