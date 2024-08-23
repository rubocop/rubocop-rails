# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EnumHash, :config do
  context 'when Rails 7 syntax is used', :rails70 do
    context 'when array syntax is used' do
      context 'with %i[] syntax' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum :status, %i[active archived]
                          ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum :status, {:active => 0, :archived => 1}
          RUBY
        end
      end

      context 'with %w[] syntax' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum :status, %w[active archived]
                          ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum :status, {"active" => 0, "archived" => 1}
          RUBY
        end
      end

      context 'with %i() syntax' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum :status, %i(active archived)
                          ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum :status, {:active => 0, :archived => 1}
          RUBY
        end
      end

      context 'with %w() syntax' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum :status, %w(active archived)
                          ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum :status, {"active" => 0, "archived" => 1}
          RUBY
        end
      end

      context 'with [] syntax' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum :status, [:active, :archived]
                          ^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum :status, {:active => 0, :archived => 1}
          RUBY
        end
      end

      context 'when the enum name is a string' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum "status", %i[active archived]
                           ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum "status", {:active => 0, :archived => 1}
          RUBY
        end
      end

      context 'when the enum name is not a literal' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum KEY, %i[active archived]
                      ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `KEY` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum KEY, {:active => 0, :archived => 1}
          RUBY
        end
      end

      it 'autocorrects' do
        expect_offense(<<~RUBY)
          enum :status, [:old, :"very active", "is archived", 42]
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum :status, {:old => 0, :"very active" => 1, "is archived" => 2, 42 => 3}
        RUBY
      end

      it 'autocorrects constants' do
        expect_offense(<<~RUBY)
          enum :status, [OLD, ACTIVE]
                        ^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum :status, {OLD => 0, ACTIVE => 1}
        RUBY
      end

      it 'autocorrects nested constants' do
        expect_offense(<<~RUBY)
          enum :status, [STATUS::OLD, STATUS::ACTIVE]
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum :status, {STATUS::OLD => 0, STATUS::ACTIVE => 1}
        RUBY
      end

      it 'autocorrects %w[] syntax' do
        expect_offense(<<~RUBY)
          enum :status, %w[active archived]
                        ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum :status, {"active" => 0, "archived" => 1}
        RUBY
      end

      it 'autocorrect %w() syntax' do
        expect_offense(<<~RUBY)
          enum :status, %w(active archived)
                        ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum :status, {"active" => 0, "archived" => 1}
        RUBY
      end

      it 'autocorrect %i[] syntax' do
        expect_offense(<<~RUBY)
          enum :status, %i[active archived]
                        ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum :status, {:active => 0, :archived => 1}
        RUBY
      end

      it 'autocorrect %i() syntax' do
        expect_offense(<<~RUBY)
          enum :status, %i(active archived)
                        ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum :status, {:active => 0, :archived => 1}
        RUBY
      end
    end

    context 'when hash syntax is used' do
      it 'does not register an offense' do
        expect_no_offenses('enum :status, { active: 0, archived: 1 }')
      end
    end
  end

  context 'when old syntax is used' do
    context 'when array syntax is used' do
      context 'with %i[] syntax' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum status: %i[active archived]
                         ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum status: {:active => 0, :archived => 1}
          RUBY
        end
      end

      context 'with %w[] syntax' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum status: %w[active archived]
                         ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum status: {"active" => 0, "archived" => 1}
          RUBY
        end
      end

      context 'with %i() syntax' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum status: %i(active archived)
                         ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum status: {:active => 0, :archived => 1}
          RUBY
        end
      end

      context 'with %w() syntax' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum status: %w(active archived)
                         ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum status: {"active" => 0, "archived" => 1}
          RUBY
        end
      end

      context 'with [] syntax' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum status: [:active, :archived]
                         ^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum status: {:active => 0, :archived => 1}
          RUBY
        end
      end

      context 'when the enum name is a string' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum "status" => %i[active archived]
                             ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum "status" => {:active => 0, :archived => 1}
          RUBY
        end
      end

      context 'when the enum name is not a literal' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum KEY => %i[active archived]
                        ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `KEY` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum KEY => {:active => 0, :archived => 1}
          RUBY
        end
      end

      context 'with multiple enum definition for a `enum` method call' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum status: %i[active archived],
                         ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
                 role: %i[owner member guest]
                       ^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `role` enum declaration. Use hash syntax instead.
          RUBY

          expect_correction(<<~RUBY)
            enum status: {:active => 0, :archived => 1},
                 role: {:owner => 0, :member => 1, :guest => 2}
          RUBY
        end
      end

      it 'autocorrects' do
        expect_offense(<<~RUBY)
          enum status: [:old, :"very active", "is archived", 42]
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum status: {:old => 0, :"very active" => 1, "is archived" => 2, 42 => 3}
        RUBY
      end

      it 'autocorrects constants' do
        expect_offense(<<~RUBY)
          enum status: [OLD, ACTIVE]
                       ^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum status: {OLD => 0, ACTIVE => 1}
        RUBY
      end

      it 'autocorrects nested constants' do
        expect_offense(<<~RUBY)
          enum status: [STATUS::OLD, STATUS::ACTIVE]
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum status: {STATUS::OLD => 0, STATUS::ACTIVE => 1}
        RUBY
      end

      it 'autocorrects %w[] syntax' do
        expect_offense(<<~RUBY)
          enum status: %w[active archived]
                       ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum status: {"active" => 0, "archived" => 1}
        RUBY
      end

      it 'autocorrect %w() syntax' do
        expect_offense(<<~RUBY)
          enum status: %w(active archived)
                       ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum status: {"active" => 0, "archived" => 1}
        RUBY
      end

      it 'autocorrect %i[] syntax' do
        expect_offense(<<~RUBY)
          enum status: %i[active archived]
                       ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum status: {:active => 0, :archived => 1}
        RUBY
      end

      it 'autocorrect %i() syntax' do
        expect_offense(<<~RUBY)
          enum status: %i(active archived)
                       ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY

        expect_correction(<<~RUBY)
          enum status: {:active => 0, :archived => 1}
        RUBY
      end
    end

    context 'when hash syntax is used' do
      it 'does not register an offense' do
        expect_no_offenses('enum status: { active: 0, archived: 1 }')
      end
    end
  end
end
