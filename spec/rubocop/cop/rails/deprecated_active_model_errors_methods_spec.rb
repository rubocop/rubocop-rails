# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DeprecatedActiveModelErrorsMethods, :config do
  shared_examples 'errors call with explicit receiver' do
    context 'when modifying errors' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY, file_path)
          user.errors[:name] << 'msg'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
        RUBY

        expect_correction(<<~RUBY)
          user.errors.add(:name, 'msg')
        RUBY
      end

      context 'when assigning' do
        it 'registers an offense' do
          expect_offense(<<~RUBY, file_path)
            user.errors[:name] = []
            ^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY
        end
      end

      context 'when using `clear` method' do
        it 'registers and corrects an offense' do
          expect_offense(<<~RUBY, file_path)
            user.errors[:name].clear
            ^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY

          expect_correction(<<~RUBY)
            user.errors.delete(:name)
          RUBY
        end
      end

      context 'when using `keys` method' do
        it 'registers and corrects an offense when root receiver is a variable' do
          expect_offense(<<~RUBY, file_path)
            user = create_user
            user.errors.keys
            ^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY

          expect_correction(<<~RUBY)
            user = create_user
            user.errors.attribute_names
          RUBY
        end

        it 'registers and corrects an offense when root receiver is a method' do
          expect_offense(<<~RUBY, file_path)
            user.errors.keys.include?(:name)
            ^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY

          expect_correction(<<~RUBY)
            user.errors.attribute_names.include?(:name)
          RUBY
        end
      end
    end

    context 'when modifying errors.messages' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY, file_path)
          user.errors.messages[:name] << 'msg'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
        RUBY

        expect_correction(<<~RUBY)
          user.errors.add(:name, 'msg')
        RUBY
      end

      context 'when assigning' do
        it 'registers an offense' do
          expect_offense(<<~RUBY, file_path)
            user.errors.messages[:name] = []
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY
        end
      end
    end

    context 'when modifying errors.details' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, file_path)
          user.errors.details[:name] << {}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
        RUBY
      end

      context 'when assigning' do
        it 'registers an offense' do
          expect_offense(<<~RUBY, file_path)
            user.errors.details[:name] = []
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY
        end
      end
    end
  end

  shared_examples 'errors call without explicit receiver' do
    def expect_offense_if_model_file(code, file_path)
      if file_path.include?('/models/')
        expect_offense(code, file_path)
      else
        code = code.gsub(/^\^+ .+$/, '')
        expect_no_offenses(code, file_path)
      end
    end

    context 'when modifying errors' do
      it 'registers an offense for model file' do
        expect_offense_if_model_file(<<~RUBY, file_path)
          errors[:name] << 'msg'
          ^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
        RUBY
      end

      context 'when assigning' do
        it 'registers an offense' do
          expect_offense_if_model_file(<<~RUBY, file_path)
            errors[:name] = []
            ^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY
        end
      end

      context 'when calling non-manipulative methods' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY, file_path)
            errors[:name].present?
          RUBY
        end
      end
    end

    context 'when modifying errors.messages' do
      it 'registers an offense' do
        expect_offense_if_model_file(<<~RUBY, file_path)
          errors.messages[:name] << 'msg'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
        RUBY
      end

      context 'when assigning' do
        it 'registers an offense' do
          expect_offense_if_model_file(<<~RUBY, file_path)
            errors.messages[:name] = []
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY
        end
      end

      context 'when calling non-manipulative methods' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY, file_path)
            errors.messages[:name].present?
          RUBY
        end
      end
    end

    context 'when modifying errors.details' do
      it 'registers an offense' do
        expect_offense_if_model_file(<<~RUBY, file_path)
          errors.details[:name] << {}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
        RUBY
      end

      context 'when assigning' do
        it 'registers an offense' do
          expect_offense_if_model_file(<<~RUBY, file_path)
            errors.details[:name] = []
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY
        end
      end

      context 'when calling non-manipulative methods' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY, file_path)
            errors.details[:name].present?
          RUBY
        end
      end
    end
  end

  context 'when file is model file' do
    let(:file_path) { '/foo/app/models/bar.rb' }

    it_behaves_like 'errors call with explicit receiver'
    it_behaves_like 'errors call without explicit receiver'
  end

  context 'when file is generic' do
    let(:file_path) { '/foo/app/lib/bar.rb' }

    it_behaves_like 'errors call with explicit receiver'
    it_behaves_like 'errors call without explicit receiver'
  end
end
