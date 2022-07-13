# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DeprecatedActiveModelErrorsMethods, :config do
  shared_examples 'errors call with explicit receiver' do
    context 'when accessing errors' do
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

          expect_no_corrections
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

      context 'Rails >= 6.1', :rails61 do
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

        context 'when using `values` method' do
          it 'registers an offense' do
            expect_offense(<<~RUBY, file_path)
              user.errors.values
              ^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
            RUBY

            expect_no_corrections
          end
        end

        context 'when using `to_h` method' do
          it 'registers an offense' do
            expect_offense(<<~RUBY, file_path)
              user.errors.to_h
              ^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
            RUBY

            expect_no_corrections
          end
        end

        context 'when using `to_xml` method' do
          it 'registers an offense' do
            expect_offense(<<~RUBY, file_path)
              user.errors.to_xml
              ^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
            RUBY

            expect_no_corrections
          end
        end
      end

      context 'Rails <= 6.0', :rails60 do
        context 'when using `keys` method' do
          it 'does not register an offense when root receiver is a variable' do
            expect_no_offenses(<<~RUBY, file_path)
              user = create_user
              user.errors.keys
            RUBY
          end

          it 'does not register an offense when root receiver is a method' do
            expect_no_offenses(<<~RUBY, file_path)
              user.errors.keys.include?(:name)
            RUBY
          end
        end

        context 'when using `values` method' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY, file_path)
              user.errors.values
            RUBY
          end
        end

        context 'when using `to_h` method' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY, file_path)
              user.errors.to_h
            RUBY
          end
        end

        context 'when using `to_xml` method' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY, file_path)
              user.errors.to_xml
            RUBY
          end
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

          expect_no_corrections
        end
      end

      context 'when using `clear` method' do
        it 'registers and corrects an offense' do
          expect_offense(<<~RUBY, file_path)
            user.errors.messages[:name].clear
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY

          expect_correction(<<~RUBY)
            user.errors.delete(:name)
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
        expect_offense(<<~RUBY, file_path)
          user.errors.details[:name] << {}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
        RUBY

        expect_no_corrections
      end

      context 'when assigning' do
        it 'registers an offense' do
          expect_offense(<<~RUBY, file_path)
            user.errors.details[:name] = []
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY

          expect_no_corrections
        end
      end

      context 'when using `clear` method' do
        it 'registers and corrects an offense' do
          expect_offense(<<~RUBY, file_path)
            user.errors.details[:name].clear
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY

          expect_correction(<<~RUBY)
            user.errors.delete(:name)
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

  shared_examples 'errors call without explicit receiver' do
    def expect_offense_if_model_file(code, file_path)
      if file_path.include?('/models/')
        expect_offense(code, file_path)
      else
        code = code.gsub(/^\^+ .+$/, '')
        expect_no_offenses(code, file_path)
      end
    end

    def expect_correction_if_model_file(code, file_path)
      expect_correction(code) if file_path.include?('/models/')
    end

    def expect_no_corrections_if_model_file(file_path)
      expect_no_corrections if file_path.include?('/models/')
    end

    context 'when accessing errors' do
      it 'registers an offense for model file' do
        expect_offense_if_model_file(<<~RUBY, file_path)
          errors[:name] << 'msg'
          ^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
        RUBY

        expect_correction_if_model_file(<<~RUBY, file_path)
          errors.add(:name, 'msg')
        RUBY
      end

      context 'when assigning' do
        it 'registers an offense' do
          expect_offense_if_model_file(<<~RUBY, file_path)
            errors[:name] = []
            ^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY

          expect_no_corrections_if_model_file(file_path)
        end
      end

      context 'when using `clear` method' do
        it 'registers and corrects an offense' do
          expect_offense_if_model_file(<<~RUBY, file_path)
            errors[:name].clear
            ^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY

          expect_correction_if_model_file(<<~RUBY, file_path)
            errors.delete(:name)
          RUBY
        end
      end

      context 'Rails >= 6.1', :rails61 do
        context 'when using `keys` method' do
          it 'registers and corrects an offense when root receiver is a variable' do
            expect_offense_if_model_file(<<~RUBY, file_path)
              errors.keys
              ^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
            RUBY

            expect_correction_if_model_file(<<~RUBY, file_path)
              errors.attribute_names
            RUBY
          end
        end

        context 'when using `values` method' do
          it 'registers an offense' do
            expect_offense_if_model_file(<<~RUBY, file_path)
              errors.values
              ^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
            RUBY

            expect_no_corrections_if_model_file(file_path)
          end
        end

        context 'when using `to_h` method' do
          it 'registers an offense' do
            expect_offense_if_model_file(<<~RUBY, file_path)
              errors.to_h
              ^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
            RUBY

            expect_no_corrections_if_model_file(file_path)
          end
        end

        context 'when using `to_xml` method' do
          it 'registers an offense' do
            expect_offense_if_model_file(<<~RUBY, file_path)
              errors.to_xml
              ^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
            RUBY

            expect_no_corrections_if_model_file(file_path)
          end
        end
      end

      context 'Rails <= 6.0', :rails60 do
        context 'when using `keys` method' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY, file_path)
              errors.keys
            RUBY
          end
        end

        context 'when using `values` method' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY, file_path)
              user.errors.values
            RUBY
          end
        end

        context 'when using `to_h` method' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY, file_path)
              user.errors.to_h
            RUBY
          end
        end

        context 'when using `to_xml` method' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY, file_path)
              user.errors.to_xml
            RUBY
          end
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

        expect_correction_if_model_file(<<~RUBY, file_path)
          errors.add(:name, 'msg')
        RUBY
      end

      context 'when assigning' do
        it 'registers an offense' do
          expect_offense_if_model_file(<<~RUBY, file_path)
            errors.messages[:name] = []
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY

          expect_no_corrections_if_model_file(file_path)
        end
      end

      context 'when using `clear` method' do
        it 'registers and corrects an offense' do
          expect_offense_if_model_file(<<~RUBY, file_path)
            errors.messages[:name].clear
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY

          expect_correction_if_model_file(<<~RUBY, file_path)
            errors.delete(:name)
          RUBY
        end
      end

      context 'when using `keys` method' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY, file_path)
            errors.messages[:name].keys
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

        expect_no_corrections_if_model_file(file_path)
      end

      context 'when assigning' do
        it 'registers an offense' do
          expect_offense_if_model_file(<<~RUBY, file_path)
            errors.details[:name] = []
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY

          expect_no_corrections_if_model_file(file_path)
        end
      end

      context 'when using `clear` method' do
        it 'registers and corrects an offense' do
          expect_offense_if_model_file(<<~RUBY, file_path)
            errors.details[:name].clear
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid manipulating ActiveModel errors as hash directly.
          RUBY

          expect_correction_if_model_file(<<~RUBY, file_path)
            errors.delete(:name)
          RUBY
        end
      end

      context 'when using `keys` method' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY, file_path)
            errors.details[:name].keys
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
