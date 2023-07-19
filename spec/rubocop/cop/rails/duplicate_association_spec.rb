# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DuplicateAssociation, :config do
  describe 'belongs_to' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class Post < ApplicationRecord
          belongs_to :foo
          ^^^^^^^^^^^^^^^ Association `foo` is defined multiple times. Don't repeat associations.
          belongs_to :bar
          belongs_to :foo
          ^^^^^^^^^^^^^^^ Association `foo` is defined multiple times. Don't repeat associations.
          belongs_to :blah
        end
      RUBY

      expect_correction(<<~RUBY)
        class Post < ApplicationRecord
          belongs_to :bar
          belongs_to :foo
          belongs_to :blah
        end
      RUBY
    end

    it 'registers an offense with scope block' do
      expect_offense(<<~RUBY)
        class Post < ApplicationRecord
          belongs_to :foo
          ^^^^^^^^^^^^^^^ Association `foo` is defined multiple times. Don't repeat associations.
          belongs_to :bar
          belongs_to :foo, -> { active }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `foo` is defined multiple times. Don't repeat associations.
          belongs_to :blah
        end
      RUBY

      expect_correction(<<~RUBY)
        class Post < ApplicationRecord
          belongs_to :bar
          belongs_to :foo, -> { active }
          belongs_to :blah
        end
      RUBY
    end
  end

  describe 'has_many' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class Post < ApplicationRecord
          has_many :foos
          ^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
          has_many :bars
          has_many :foos
          ^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
          has_many :blahs
        end
      RUBY

      expect_correction(<<~RUBY)
        class Post < ApplicationRecord
          has_many :bars
          has_many :foos
          has_many :blahs
        end
      RUBY
    end

    it 'registers an offense with scope block' do
      expect_offense(<<~RUBY)
        class Post < ApplicationRecord
          has_many :foos
          ^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
          has_many :bars
          has_many 'foos', -> { active }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
          has_many :blahs
        end
      RUBY

      expect_correction(<<~RUBY)
        class Post < ApplicationRecord
          has_many :bars
          has_many 'foos', -> { active }
          has_many :blahs
        end
      RUBY
    end
  end

  describe 'has_one' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class Post < ApplicationRecord
          has_one :foo
          ^^^^^^^^^^^^ Association `foo` is defined multiple times. Don't repeat associations.
          has_one :bar
          has_one :foo
          ^^^^^^^^^^^^ Association `foo` is defined multiple times. Don't repeat associations.
          has_one :blah
        end
      RUBY

      expect_correction(<<~RUBY)
        class Post < ApplicationRecord
          has_one :bar
          has_one :foo
          has_one :blah
        end
      RUBY
    end

    it 'registers an offense with scope block' do
      expect_offense(<<~RUBY)
        class Post < ApplicationRecord
          has_one :foo
          ^^^^^^^^^^^^ Association `foo` is defined multiple times. Don't repeat associations.
          has_one :bar
          has_one :foo, -> { active }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `foo` is defined multiple times. Don't repeat associations.
          has_one :blah
        end
      RUBY

      expect_correction(<<~RUBY)
        class Post < ApplicationRecord
          has_one :bar
          has_one :foo, -> { active }
          has_one :blah
        end
      RUBY
    end
  end

  describe 'has_and_belongs_to_many' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class Post < ApplicationRecord
          has_and_belongs_to_many :foos
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
          has_and_belongs_to_many :bars
          has_and_belongs_to_many :foos
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
          has_and_belongs_to_many :blahs
        end
      RUBY

      expect_correction(<<~RUBY)
        class Post < ApplicationRecord
          has_and_belongs_to_many :bars
          has_and_belongs_to_many :foos
          has_and_belongs_to_many :blahs
        end
      RUBY
    end

    it 'registers an offense with scope block' do
      expect_offense(<<~RUBY)
        class Post < ApplicationRecord
          has_and_belongs_to_many :foos
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
          has_and_belongs_to_many :bars
          has_and_belongs_to_many :foos, -> { active }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
          has_and_belongs_to_many :blahs
        end
      RUBY

      expect_correction(<<~RUBY)
        class Post < ApplicationRecord
          has_and_belongs_to_many :bars
          has_and_belongs_to_many :foos, -> { active }
          has_and_belongs_to_many :blahs
        end
      RUBY
    end
  end

  describe 'all associations' do
    it 'marks offenses for duplicate associations of differing types' do
      expect_offense(<<~RUBY)
        class Post < ApplicationRecord
          has_many :foos
          ^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
          has_and_belongs_to_many :foos
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
          has_and_belongs_to_many :bars
          has_and_belongs_to_many :foos, -> { active }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
          has_and_belongs_to_many :blahs

          has_one :author
          ^^^^^^^^^^^^^^^ Association `author` is defined multiple times. Don't repeat associations.
          has_one :top_comment, -> { order(likes: :desc) }, class_name: 'Comment'
          belongs_to :author
          ^^^^^^^^^^^^^^^^^^ Association `author` is defined multiple times. Don't repeat associations.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Post < ApplicationRecord
          has_and_belongs_to_many :bars
          has_and_belongs_to_many :foos, -> { active }
          has_and_belongs_to_many :blahs

          has_one :top_comment, -> { order(likes: :desc) }, class_name: 'Comment'
          belongs_to :author
        end
      RUBY
    end

    it 'does not flag non-duplicate associations' do
      expect_no_offenses(<<-RUBY)
        class Post < ApplicationRecord
          belongs_to :user

          has_many :comments
          has_many :commenters, through: :comments

          has_many :active_comments, -> { active }, class_name: 'Comment'

          has_one :top_comment, -> { order(likes: :desc) }, class_name: 'Comment'

          has_and_belongs_to_many :related_posts, class_name: 'Post'
        end
      RUBY
    end
  end

  describe 'a class that does not descend from Active Record' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY)
        class Post < ActiveModel::Serializer
          has_many :comments, key: :remarks, if: :formal_mode?
          has_many :comments, key: :rejoinders, if: :debate_mode?
        end
      RUBY
    end
  end
end
