# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RedundantPresenceValidationOnBelongsTo, :config do
  context 'Rails >= 5.0', :rails50 do
    context 'with an explicit redundant presence validation for a required belongs_to association' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          belongs_to :user
          validates :user, presence: true
                           ^^^^^^^^^^^^^^ Remove explicit presence validation for `user`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :user
        RUBY
      end

      it 'registers an offense for the default foreign key' do
        expect_offense(<<~RUBY)
          belongs_to :user
          validates :user_id, presence: true
                              ^^^^^^^^^^^^^^ Remove explicit presence validation for `user_id`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :user
        RUBY
      end

      it 'registers an offense when belongs_to has an explicit foreign key' do
        expect_offense(<<~RUBY)
          belongs_to :author, foreign_key: :user_id
          validates :user_id, presence: true
                              ^^^^^^^^^^^^^^ Remove explicit presence validation for `user_id`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :author, foreign_key: :user_id
        RUBY
      end

      it 'registers an offense when belongs_to has an explicit foreign key with other options' do
        expect_offense(<<~RUBY)
          belongs_to :author, class_name: 'User', foreign_key: :user_id
          validates :user_id, presence: true
                              ^^^^^^^^^^^^^^ Remove explicit presence validation for `user_id`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :author, class_name: 'User', foreign_key: :user_id
        RUBY
      end

      it 'registers an offense even when belongs_to has an explicit foreign key' do
        expect_offense(<<~RUBY)
          belongs_to :author, foreign_key: :user_id
          validates :author, presence: true
                             ^^^^^^^^^^^^^^ Remove explicit presence validation for `author`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :author, foreign_key: :user_id
        RUBY
      end

      it 'registers an offense when association is defined with a scope' do
        expect_offense(<<~RUBY)
          belongs_to :user, -> { not_deleted }
          validates :user, presence: true
                           ^^^^^^^^^^^^^^ Remove explicit presence validation for `user`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :user, -> { not_deleted }
        RUBY
      end

      it 'registers an offense even when validates has other preceding options' do
        expect_offense(<<~RUBY)
          belongs_to :user
          validates :user, uniqueness: true, presence: true
                                             ^^^^^^^^^^^^^^ Remove explicit presence validation for `user`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :user
          validates :user, uniqueness: true
        RUBY
      end

      it 'registers an offense even when validates has other trailing options' do
        expect_offense(<<~RUBY)
          belongs_to :user
          validates :user, presence: true, uniqueness: true
                           ^^^^^^^^^^^^^^ Remove explicit presence validation for `user`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :user
          validates :user, uniqueness: true
        RUBY
      end

      it 'registers an offense for multiple associations' do
        expect_offense(<<~RUBY)
          belongs_to :user
          belongs_to :book
          validates :user, :book, presence: true
                                  ^^^^^^^^^^^^^^ Remove explicit presence validation for `user`/`book`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :user
          belongs_to :book
        RUBY
      end

      it 'registers an offense for multiple attributes when not all are associations' do
        expect_offense(<<~RUBY)
          belongs_to :user
          validates :user, :name, presence: true
                                  ^^^^^^^^^^^^^^ Remove explicit presence validation for `user`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :user
          validates :name, presence: true
        RUBY
      end

      it 'registers an offense for a secondary attribute' do
        expect_offense(<<~RUBY)
          belongs_to :user
          validates :name, :user, presence: true
                                  ^^^^^^^^^^^^^^ Remove explicit presence validation for `user`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :user
          validates :name, presence: true
        RUBY
      end

      it 'registers an offense for multiple attributes and options' do
        expect_offense(<<~RUBY)
          belongs_to :user
          validates :user, :name, presence: true, uniqueness: true
                                  ^^^^^^^^^^^^^^ Remove explicit presence validation for `user`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :user
          validates :name, presence: true, uniqueness: true
          validates :user, uniqueness: true
        RUBY
      end

      it 'preserves indentation for the extracted validation line' do
        expect_offense(<<~RUBY)
          class Profile
            belongs_to :user
            validates :user, :name, presence: true, uniqueness: true
                                    ^^^^^^^^^^^^^^ Remove explicit presence validation for `user`.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Profile
            belongs_to :user
            validates :name, presence: true, uniqueness: true
            validates :user, uniqueness: true
          end
        RUBY
      end

      it 'does not register an offense for presence with a message' do
        expect_no_offenses(<<~RUBY)
          belongs_to :user
          validates :user, presence: { message: 'Must be present' }
        RUBY
      end

      it 'registers an offense for multiple attributes and options in belongs_to' do
        expect_offense(<<~RUBY)
          belongs_to :user, -> { where(foo: true) }, inverse_of: :employee
          validates :user_id, presence: true
                              ^^^^^^^^^^^^^^ Remove explicit presence validation for `user_id`.
        RUBY
      end

      it 'registers an offense even when the presence option is factored out' do
        pending 'Not yet implemented.'

        expect_offense(<<~RUBY)
          belongs_to :user
          with_options presence: true do
                       ^^^^^^^^^^^^^^ Remove explicit presence validation for `:user`.
            validates :user
          end
        RUBY
      end

      it 'registers an offense for non-absence option' do
        pending 'Not yet implemented.'

        expect_offense(<<~RUBY)
          belongs_to :user
          validates :user, absence: false
                           ^^^^^^^^^^^^^^ Remove explicit presence validation for `:user`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :user
        RUBY
      end

      it 'registers an offense when validation key is a string' do
        pending 'Not yet implemented.'

        expect_offense(<<~RUBY)
          belongs_to :user
          validates 'user', presence: true
                            ^^^^^^^^^^^^^^ Remove explicit presence validation for `user`.
        RUBY

        expect_correction(<<~RUBY)
          belongs_to :user
        RUBY
      end
    end

    it 'does not register an offense with redundant presence' do
      expect_no_offenses(<<~RUBY)
        belongs_to :user
        validates :user_count, presence: true
      RUBY
    end

    it 'does not register an offense with presence validation turned off' do
      expect_no_offenses(<<~RUBY)
        belongs_to :user
        validates :user_id, presence: false
      RUBY
    end

    it 'does not register an offense with an optional belongs_to' do
      expect_no_offenses(<<~RUBY)
        belongs_to :user, optional: true
        validates :user_id, presence: true
      RUBY
    end

    it 'does not register an offense with a non-required belongs_to' do
      expect_no_offenses(<<~RUBY)
        belongs_to :user, required: false
        validates :user_id, presence: true
      RUBY
    end

    it 'does not register an offense when foreign keys do not match' do
      expect_no_offenses(<<~RUBY)
        belongs_to :author, foreign_key: :user_id
        validates :author_id, presence: true
      RUBY
    end

    it 'does not register an offense for optional association with explicit foreign key' do
      expect_no_offenses(<<~RUBY)
        belongs_to :author, foreign_key: :user_id, optional: true
        validates :author, presence: true
      RUBY
    end

    it 'does not register an offense with `if` option' do
      expect_no_offenses(<<~RUBY)
        belongs_to :user
        validates :user, presence: true, if: -> { condition }
      RUBY
    end

    it 'does not register an offense with `unless` option' do
      expect_no_offenses(<<~RUBY)
        belongs_to :user
        validates :user, presence: true, unless: -> { condition }
      RUBY
    end

    it 'does not register an offense with strict validation' do
      expect_no_offenses(<<~RUBY)
        belongs_to :user
        validates :user, presence: true, strict: true
      RUBY
    end

    it 'does not register an offense with strict validation with an explicit exception class' do
      expect_no_offenses(<<~RUBY)
        belongs_to :user
        validates :user, presence: true, strict: MissingUserError
      RUBY
    end
  end

  context 'Rails < 5.0', :rails42 do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        belongs_to :user # belongs_to is optional by default in Rails 4.2
        validates :user, presence: true
      RUBY
    end
  end
end
