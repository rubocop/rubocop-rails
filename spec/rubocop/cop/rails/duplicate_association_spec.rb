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
          belongs_to :foo
          belongs_to :bar
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
          belongs_to :foo, -> { active }
          belongs_to :bar
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
          has_many :foos
          has_many :bars
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
          has_many 'foos', -> { active }
          has_many :bars
          has_many :blahs
        end
      RUBY
    end

    it 'registers an offense with alias' do
      expect_offense(<<~RUBY)
        class Post < ApplicationRecord
          belongs_to :foos, -> { active }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
          alias bars foos
          belongs_to :foos
          ^^^^^^^^^^^^^^^^ Association `foos` is defined multiple times. Don't repeat associations.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Post < ApplicationRecord
          belongs_to :foos
          alias bars foos
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
          has_one :foo
          has_one :bar
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
          has_one :foo, -> { active }
          has_one :bar
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
          has_and_belongs_to_many :foos
          has_and_belongs_to_many :bars
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
          has_and_belongs_to_many :foos, -> { active }
          has_and_belongs_to_many :bars
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
          has_and_belongs_to_many :foos, -> { active }
          has_and_belongs_to_many :bars
          has_and_belongs_to_many :blahs

          belongs_to :author
          has_one :top_comment, -> { order(likes: :desc) }, class_name: 'Comment'
        end
      RUBY
    end

    it 'registers offenses when using duplicate `has_*` associations of same class without other arguments' do
      expect_offense(<<~RUBY)
        class Post < ApplicationRecord
          has_many :foos, class_name: 'Foo'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `class_name: 'Foo'` is defined multiple times. Don't repeat associations.
          has_many :bars, class_name: 'Foo'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `class_name: 'Foo'` is defined multiple times. Don't repeat associations.

          has_one :baz, class_name: 'Bar'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `class_name: 'Bar'` is defined multiple times. Don't repeat associations.
          has_one :qux, class_name: 'Bar'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Association `class_name: 'Bar'` is defined multiple times. Don't repeat associations.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Post < ApplicationRecord
          has_many :bars, class_name: 'Foo'

          has_one :qux, class_name: 'Bar'
        end
      RUBY
    end

    it 'does not register an offenses when using duplicate `belongs_to` assocs of same class without other args' do
      expect_no_offenses(<<~RUBY)
        class Post < ApplicationRecord
          belongs_to :foos, class_name: 'Foo'
          belongs_to :bars, class_name: 'Foo'
        end
      RUBY
    end

    it 'does not register an offense when using duplicate associations of same class with other arguments' do
      expect_no_offenses(<<~RUBY)
        class Post < ApplicationRecord
          has_many :foos, if: condition, class_name: 'Foo'
          has_many :bars, if: some_condition, class_name: 'Foo'

          has_one :baz, -> { condition }, class_name: 'Bar'
          has_one :qux, -> { some_condition }, class_name: 'Bar'

          belongs_to :group, class_name: 'IndustryGroup', foreign_key: :industry_group_id
        end
      RUBY
    end

    it 'does not register an offense when not using association method' do
      expect_no_offenses(<<~RUBY)
        class Post < ApplicationRecord
          validates_presence_of :name
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
