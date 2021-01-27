# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RedundantForeignKey, :config do
  context '`belongs_to` associations' do
    it 'registers an offense when the `:foreign_key` option is redundant' do
      expect_offense(<<~RUBY)
        class Comment
          belongs_to :post, foreign_key: 'post_id'
                            ^^^^^^^^^^^^^^^^^^^^^^ Specifying the default value for `foreign_key` is redundant.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Comment
          belongs_to :post
        end
      RUBY
    end

    it 'does not register an offense when the `:foreign_key` option is not redundant' do
      expect_no_offenses(<<~RUBY)
        class Comment
          belongs_to :author, foreign_key: 'user_id'
        end
      RUBY
    end

    it 'does not register an offense when the `:foreign_key` option is absent' do
      expect_no_offenses(<<~RUBY)
        class Comment
          belongs_to :author
        end
      RUBY
    end

    it 'registers an offense even when other options are used' do
      expect_offense(<<~RUBY)
        class Comment
          belongs_to :post, class_name: 'SpecialPost', foreign_key: 'post_id', dependent: :destroy
                                                       ^^^^^^^^^^^^^^^^^^^^^^ Specifying the default value for `foreign_key` is redundant.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Comment
          belongs_to :post, class_name: 'SpecialPost', dependent: :destroy
        end
      RUBY
    end

    it 'registers an offense even when defined in a block' do
      expect_offense(<<~RUBY)
        class_methods do
          belongs_to :post, foreign_key: 'post_id'
                            ^^^^^^^^^^^^^^^^^^^^^^ Specifying the default value for `foreign_key` is redundant.
        end
      RUBY

      expect_correction(<<~RUBY)
        class_methods do
          belongs_to :post
        end
      RUBY
    end
  end

  %w[has_one has_many has_and_belongs_to_many].each do |association_type|
    context "`#{association_type}` associations" do
      it 'registers an offense when the `:foreign_key` option is redundant' do
        expect_offense(<<~RUBY, association_type: association_type)
          class Book
            %{association_type} :chapter, foreign_key: 'book_id'
            _{association_type}           ^^^^^^^^^^^^^^^^^^^^^^ Specifying the default value for `foreign_key` is redundant.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Book
            #{association_type} :chapter
          end
        RUBY
      end

      it 'does not register an offense when the `:foreign_key` option is not redundant' do
        expect_no_offenses(<<~RUBY)
          class Book
            #{association_type} :chapter, foreign_key: 'publication_id'
          end
        RUBY
      end

      it 'does not register an offense when the `:foreign_key` option is absent' do
        expect_no_offenses(<<~RUBY)
          class Book
            #{association_type} :chapter
          end
        RUBY
      end

      it 'registers an offense even when other options are used' do
        expect_offense(<<~RUBY, association_type: association_type)
          class Book
            %{association_type} :chapter, class_name: 'SpecialChapter', foreign_key: 'book_id', dependent: :destroy
            _{association_type}                                         ^^^^^^^^^^^^^^^^^^^^^^ Specifying the default value for `foreign_key` is redundant.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Book
            #{association_type} :chapter, class_name: 'SpecialChapter', dependent: :destroy
          end
        RUBY
      end

      it 'registers an offense even when multiple associations are defined' do
        expect_offense(<<~RUBY, association_type: association_type)
          class Book
            belongs_to :series

            %{association_type} :chapter, foreign_key: 'book_id'
            _{association_type}           ^^^^^^^^^^^^^^^^^^^^^^ Specifying the default value for `foreign_key` is redundant.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Book
            belongs_to :series

            #{association_type} :chapter
          end
        RUBY
      end

      it 'does not register an offense when defined in a block' do
        expect_no_offenses(<<~RUBY)
          class_methods do
            #{association_type} :chapter, foreign_key: 'book_id'
          end
        RUBY
      end

      it 'registers an offense when the `:foreign_key` options is redundant with the `:as` option' do
        expect_offense(<<~RUBY, association_type: association_type)
          class Book
            %{association_type} :chapter, as: :publishable, foreign_key: 'publishable_id'
            _{association_type}                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specifying the default value for `foreign_key` is redundant.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Book
            #{association_type} :chapter, as: :publishable
          end
        RUBY
      end

      it 'does not register an offense when the `:foreign_key` option is not redundant with the `:as` option' do
        expect_no_offenses(<<~RUBY)
          class Book
            #{association_type} :chapter, as: :publishable, foreign_key: 'book_id'
          end
        RUBY
      end

      it 'does not register an offense when the class cannot be determined' do
        expect_no_offenses(<<~RUBY)
          #{association_type} :chapter, foreign_key: 'book_id'
        RUBY
      end
    end
  end
end
