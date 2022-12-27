# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActiveRecordAliases, :config do
  describe '#update_attributes' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        book.update_attributes(author: "Alice")
             ^^^^^^^^^^^^^^^^^ Use `update` instead of `update_attributes`.
      RUBY

      expect_correction(<<~RUBY)
        book.update(author: "Alice")
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          book&.update_attributes(author: "Alice")
                ^^^^^^^^^^^^^^^^^ Use `update` instead of `update_attributes`.
        RUBY

        expect_correction(<<~RUBY)
          book&.update(author: "Alice")
        RUBY
      end
    end

    context 'when arguments of `update_attributes` is empty' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          user.update(update_attributes)
        RUBY
      end
    end
  end

  describe '#update_attributes!' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        book.update_attributes!(author: "Bob")
             ^^^^^^^^^^^^^^^^^^ Use `update!` instead of `update_attributes!`.
      RUBY

      expect_correction(<<~RUBY)
        book.update!(author: "Bob")
      RUBY
    end
  end

  describe '#update' do
    it 'does not register an offense' do
      expect_no_offenses('book.update(author: "Alice")')
    end
  end

  describe '#update!' do
    it 'does not register an offense' do
      expect_no_offenses('book.update!(author: "Bob")')
    end
  end

  describe 'other use of the `update_attributes` string' do
    it 'registers and corrects the other usage' do
      expect_offense(<<~RUBY)
        update_attributes_book.update_attributes(author: "Alice")
                               ^^^^^^^^^^^^^^^^^ Use `update` instead of `update_attributes`.
      RUBY

      expect_correction(<<~RUBY)
        update_attributes_book.update(author: "Alice")
      RUBY
    end
  end
end
