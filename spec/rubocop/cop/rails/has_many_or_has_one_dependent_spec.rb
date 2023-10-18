# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::HasManyOrHasOneDependent, :config do
  context 'has_one' do
    it 'registers an offense when not specifying any options' do
      expect_offense(<<~RUBY)
        class Person < ApplicationRecord
          has_one :foo
          ^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'registers an offense when missing an explicit `:dependent` strategy' do
      expect_offense(<<~RUBY)
        class Person < ApplicationRecord
          has_one :foo, class_name: 'bar'
          ^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'does not register an offense when specifying `:dependent` strategy' do
      expect_no_offenses(<<~RUBY)
        class Person < ApplicationRecord
          has_one :foo, dependent: :destroy
        end
      RUBY
    end

    it 'does not register an offense when specifying `:dependent` strategy with double splat' do
      expect_no_offenses(<<~RUBY)
        class Person < ApplicationRecord
          has_one :foo, **{dependent: :destroy}
        end
      RUBY
    end

    it 'registers an offense when a variable passed with double splat' do
      expect_offense(<<~RUBY)
        class Person < ApplicationRecord
          has_one :foo, **bar
          ^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'does not register an offense when specifying default `dependent: nil` strategy' do
      expect_no_offenses(<<~RUBY)
        class Person < ApplicationRecord
          has_one :foo, dependent: nil
        end
      RUBY
    end

    context 'with :through option' do
      it 'does not register an offense for non-nil value' do
        expect_no_offenses(<<~RUBY)
          class Person < ApplicationRecord
            has_one :foo, through: :bar
          end
        RUBY
      end

      it 'registers an offense for nil value' do
        expect_offense(<<~RUBY)
          class Person < ApplicationRecord
            has_one :foo, through: nil
            ^^^^^^^ Specify a `:dependent` option.
          end
        RUBY
      end
    end

    context 'with_options dependent: :destroy' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class Person < ApplicationRecord
            with_options dependent: :destroy do
              has_one :foo
            end
          end
        RUBY
      end

      it 'does not register an offense for using `class_name` option' do
        expect_no_offenses(<<~RUBY)
          class Person < ApplicationRecord
            with_options dependent: :destroy do
              has_one :foo, class_name: 'Foo'
            end
          end
        RUBY
      end

      it 'does not register an offense when has_one called on explicit receiver' do
        expect_no_offenses(<<~RUBY)
          class Person < ApplicationRecord
            with_options dependent: :destroy do |model|
              model.has_one :foo
            end
          end
        RUBY
      end
    end
  end

  context 'has_many' do
    it 'registers an offense when not specifying any options' do
      expect_offense(<<~RUBY)
        class Person < ApplicationRecord
          has_many :foo
          ^^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'registers an offense when missing an explicit `:dependent` strategy' do
      expect_offense(<<~RUBY)
        class Person < ApplicationRecord
          has_many :foo, class_name: 'bar'
          ^^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'registers an offense when using lambda argument and not specifying any options' do
      expect_offense(<<~RUBY)
        class User < ApplicationRecord
          has_many :articles, -> { where(active: true) }
          ^^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    it 'does not register an offense when specifying `:dependent` strategy' do
      expect_no_offenses('has_many :foo, dependent: :bar')
    end

    it 'does not register an offense when using lambda argument and specifying `:dependent` strategy' do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          has_many :articles, -> { where(active: true) }, dependent: :destroy
        end
      RUBY
    end

    it 'does not register an offense when specifying default `dependent: nil` strategy' do
      expect_no_offenses(<<~RUBY)
        class Person < ApplicationRecord
          has_many :foo, dependent: nil
        end
      RUBY
    end

    context 'with :through option' do
      it 'does not register an offense for non-nil value' do
        expect_no_offenses('has_many :foo, through: :bars')
      end

      it 'does not register an offense when using lambda argument and specifying non-nil `:through` option' do
        expect_no_offenses(<<~RUBY)
          class User < ApplicationRecord
            has_many :activities, -> { order(created_at: :desc) }, through: :notes, source: :activities
          end
        RUBY
      end

      it 'registers an offense for nil value' do
        expect_offense(<<~RUBY)
          class Person < ApplicationRecord
            has_many :foo, through: nil
            ^^^^^^^^ Specify a `:dependent` option.
          end
        RUBY
      end
    end

    context 'Surrounded `with_options` block' do
      it 'registers an offense when `dependent: :destroy` is not present' do
        expect_offense(<<~RUBY)
          class Person < ApplicationRecord
            with_options through: nil do
              has_many :foo
              ^^^^^^^^ Specify a `:dependent` option.
            end
          end
        RUBY
      end

      it "doesn't register an offense for `with_options dependent: :destroy`" do
        expect_no_offenses(<<~RUBY)
          class Person < ApplicationRecord
            with_options dependent: :destroy do
              has_many :foo
            end
          end
        RUBY
      end

      it 'does not register an offense when has_many called on explicit receiver' do
        expect_no_offenses(<<~RUBY)
          class Person < ApplicationRecord
            with_options dependent: :destroy do |model|
              model.has_many :foo
            end
          end
        RUBY
      end

      it "doesn't register an offense for `with_options dependent: :destroy` and for using association extension" do
        expect_no_offenses(<<~RUBY)
          class Person < ApplicationRecord
            with_options dependent: :destroy do
              has_many :foo do
                def bar
                end
              end
            end
          end
        RUBY
      end

      context 'Multiple associations' do
        it "doesn't register an offense for `with_options dependent: :destroy`" do
          expect_no_offenses(<<~RUBY)
            class Person < ApplicationRecord
              with_options dependent: :destroy do
                has_many :foo
                has_many :bar
              end
            end
          RUBY
        end
      end
    end

    context 'Nested `with_options` block' do
      it 'does not register an offense when `dependent: :destroy` is present' do
        expect_no_offenses(<<~RUBY)
          class Article < ApplicationRecord
            with_options dependent: :destroy do
              has_many :tags
              with_options class_name: 'Tag' do
                has_many :special_tags, foreign_key: :special_id, inverse_of: :special
              end
            end
          end
        RUBY
      end
    end
  end

  context 'base-class check' do
    it 'registers an offense for `ActiveRecord::Base` class' do
      expect_offense(<<~RUBY)
        class Person < ActiveRecord::Base
          has_one :foo
          ^^^^^^^ Specify a `:dependent` option.
        end
      RUBY
    end

    context 'mix-in module' do
      it 'registers an offense when has an association of Active Record' do
        expect_offense(<<~RUBY)
          module Foo
            extend ActiveSupport::Concern

            included do
              has_many :bazs
              ^^^^^^^^ Specify a `:dependent` option.
            end
          end
        RUBY
      end

      it 'registers an offense when association method is called on the base class and no `:dependent` strategy' do
        expect_offense(<<~RUBY)
          module Foo
            def self.included(base)
              base.has_many :bazs
                   ^^^^^^^^ Specify a `:dependent` option.
            end
          end
        RUBY
      end

      it 'does not register an offense when association method is called on the base class' \
         'and has `:dependent` strategy' do
        expect_no_offenses(<<~RUBY)
          module Foo
            def self.included(base)
              base.has_many :bazs, dependent: :destroy
            end
          end
        RUBY
      end
    end

    it 'does not register an offense when using associations of Active Resource' do
      expect_no_offenses(<<~RUBY)
        class User < ActiveResource::Base
          has_many :projects, class_name: 'API::Project'
        end
      RUBY
    end

    it 'does not register an offense when using associations of Active Resource and `::ActiveResource::Base`' do
      expect_no_offenses(<<~RUBY)
        class User < ::ActiveResource::Base
          has_many :projects, class_name: 'API::Project'
        end
      RUBY
    end
  end

  context 'when defining `readonly?` method' do
    it 'does not register an offense for `readonly?` is `true`' do
      expect_no_offenses(<<~RUBY)
        class Person < ActiveRecord::Base
          has_one :foo

          def readonly?
            true
          end
        end
      RUBY
    end

    it 'registers an offense for `readonly?` is not `true`' do
      expect_offense(<<~RUBY)
        class Person < ActiveRecord::Base
          has_one :foo
          ^^^^^^^ Specify a `:dependent` option.

          def readonly?
            false
          end
        end
      RUBY
    end
  end

  context 'when an Active Record model does not have any associations' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Person < ApplicationRecord
        end
      RUBY
    end
  end
end
