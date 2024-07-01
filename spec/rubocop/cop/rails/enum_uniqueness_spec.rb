# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EnumUniqueness, :config do
  context 'when Rails 7 syntax is used' do
    context 'when array syntax is used' do
      context 'without options' do
        context 'with a single duplicated enum value' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              enum :status, [:active, :archived, :active]
                                                 ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
            RUBY
          end
        end

        context 'with several duplicated enum values' do
          it 'registers two offenses' do
            expect_offense(<<~RUBY)
              enum :status, [:active, :archived, :active, :active]
                                                          ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
                                                 ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
            RUBY
          end
        end

        context 'with no duplicated enum values' do
          it 'does not register an offense for unique enum values' do
            expect_no_offenses('enum :status, [:active, :archived]')
          end
        end
      end

      context 'with options' do
        context 'with a single duplicated enum value' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              enum :status, [:active, :archived, :active], default: :active, prefix: true
                                                 ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
            RUBY
          end
        end

        context 'with several duplicated enum values' do
          it 'registers two offenses' do
            expect_offense(<<~RUBY)
              enum :status, [:active, :archived, :active, :active], default: :active, prefix: true
                                                          ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
                                                 ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
            RUBY
          end
        end

        context 'with no duplicated enum values' do
          it 'does not register an offense for unique enum values' do
            expect_no_offenses('enum :status, [:active, :archived], default: :active, prefix: true')
          end
        end
      end
    end

    context 'when hash syntax is used' do
      context 'without options' do
        context 'with a single duplicated enum value' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              enum :status, { active: 0, archived: 0 }
                                                   ^ Duplicate value `0` found in `status` enum declaration.
            RUBY
          end
        end

        context 'with several duplicated enum values' do
          it 'registers two offenses' do
            expect_offense(<<~RUBY)
              enum :status, { active: 0, pending: 0, archived: 0 }
                                                               ^ Duplicate value `0` found in `status` enum declaration.
                                                  ^ Duplicate value `0` found in `status` enum declaration.
            RUBY
          end
        end

        context 'with no duplicated enum values' do
          it 'does not register an offense' do
            expect_no_offenses('enum status: { active: 0, pending: 1 }')
          end
        end
      end

      context 'with options' do
        context 'with a single duplicated enum value' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              enum :status, { active: 0, archived: 0 }, default: :active, prefix: true
                                                   ^ Duplicate value `0` found in `status` enum declaration.
            RUBY
          end
        end

        context 'with several duplicated enum values' do
          it 'registers two offenses' do
            expect_offense(<<~RUBY)
              enum :status, { active: 0, pending: 0, archived: 0 }, default: :active, prefix: true
                                                               ^ Duplicate value `0` found in `status` enum declaration.
                                                  ^ Duplicate value `0` found in `status` enum declaration.
            RUBY
          end
        end

        context 'with no duplicated enum values' do
          it 'does not register an offense' do
            expect_no_offenses('enum status: { active: 0, pending: 1 }, default: :active, prefix: true')
          end
        end
      end
    end

    context 'when receiving a hash without literal values' do
      context 'when value is a variable' do
        it 'does not register an offense' do
          expect_no_offenses('enum :status, statuses')
        end
      end

      context 'when value is a method chain' do
        it 'does not register an offense' do
          expect_no_offenses('enum :status, User.statuses.keys')
        end
      end

      context 'when value is a constant' do
        it 'does not register an offense' do
          expect_no_offenses('enum :status, STATUSES')
        end
      end
    end

    context 'when the enum name is a string' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum "status", [:active, :archived, :active]
                                              ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
        RUBY
      end
    end

    context 'when the enum name is not a literal' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum KEY, [:active, :archived, :active]
                                         ^^^^^^^ Duplicate value `:active` found in `KEY` enum declaration.
        RUBY
      end
    end
  end

  context 'when old syntax is used' do
    context 'when array syntax is used' do
      context 'with a single duplicated enum value' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum status: [:active, :archived, :active]
                                              ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
          RUBY
        end
      end

      context 'with several duplicated enum values' do
        it 'registers two offenses' do
          expect_offense(<<~RUBY)
            enum status: [:active, :archived, :active, :active]
                                                       ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
                                              ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
          RUBY
        end
      end

      context 'with no duplicated enum values' do
        it 'does not register an offense for unique enum values' do
          expect_no_offenses('enum status: [:active, :archived]')
        end
      end
    end

    context 'when hash syntax is used' do
      context 'with a single duplicated enum value' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum status: { active: 0, archived: 0 }
                                                ^ Duplicate value `0` found in `status` enum declaration.
          RUBY
        end
      end

      context 'with several duplicated enum values' do
        it 'registers two offenses' do
          expect_offense(<<~RUBY)
            enum status: { active: 0, pending: 0, archived: 0 }
                                                            ^ Duplicate value `0` found in `status` enum declaration.
                                               ^ Duplicate value `0` found in `status` enum declaration.
          RUBY
        end
      end

      context 'with no duplicated enum values' do
        it 'does not register an offense' do
          expect_no_offenses('enum status: { active: 0, pending: 1 }')
        end
      end
    end

    context 'when receiving a variable' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          var = { status: { active: 0, archived: 1 } }
          enum var
        RUBY
      end
    end

    context 'when receiving a hash without literal values' do
      context 'when value is a variable' do
        it 'does not register an offense' do
          expect_no_offenses('enum status: statuses')
        end
      end

      context 'when value is a method chain' do
        it 'does not register an offense' do
          expect_no_offenses('enum status: User.statuses.keys')
        end
      end

      context 'when value is a constant' do
        it 'does not register an offense' do
          expect_no_offenses('enum status: STATUSES')
        end
      end
    end

    context 'when the enum name is a string' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum "status" => [:active, :archived, :active]
                                                ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
        RUBY
      end
    end

    context 'when the enum name is not a literal' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum KEY => [:active, :archived, :active]
                                           ^^^^^^^ Duplicate value `:active` found in `KEY` enum declaration.
        RUBY
      end
    end

    context 'with multiple enum definition for a `enum` method call' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: [:active, :archived, :active],
                                            ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
              role: [:owner, :member, :guest, :member]
                                              ^^^^^^^ Duplicate value `:member` found in `role` enum declaration.
        RUBY
      end
    end
  end
end
