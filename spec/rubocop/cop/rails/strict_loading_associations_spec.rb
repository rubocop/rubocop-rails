# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::StrictLoadingAssociations, :config do
  context 'when using Rails 6.1 or newer', :rails61 do
    it 'registers an offense when not declaring `strict_loading`' do
      expect_offense(<<~RUBY)
        class Author < ApplicationRecord
          has_many :posts
          ^^^^^^^^^^^^^^^ Declare a `strict_loading` option on `has_many` associations.
        end
      RUBY
    end

    it 'does not register an offense when declaring `strict_loading`' do
      expect_no_offenses(<<~RUBY)
        class Author < ApplicationRecord
          has_many :posts, strict_loading: true
        end
      RUBY
    end
  end

  context 'when using Rails 6.0 or older', :rails60 do
    it 'does not register an offense when not declaring `strict_loading`' do
      expect_no_offenses(<<~RUBY)
        class Author < ApplicationRecord
          has_many :posts
        end
      RUBY
    end
  end
end
