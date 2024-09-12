# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EnumSyntax, :config do
  context 'Rails >= 7.0 and Ruby >= 3.0', :rails70, :ruby30 do
    context 'when keyword arguments are used' do
      context 'with %i[] syntax' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum status: %i[active archived], _prefix: true
                         ^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments in `status` enum declaration. Use positional arguments instead.
          RUBY

          expect_correction(<<~RUBY)
            enum :status, %i[active archived], prefix: true
          RUBY
        end
      end

      context 'with %i[] syntax with multiple enum definitions' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum x: %i[foo bar], y: %i[baz qux]
                    ^^^^^^^^^^^ Enum defined with keyword arguments in `x` enum declaration. Use positional arguments instead.
                                    ^^^^^^^^^^^ Enum defined with keyword arguments in `y` enum declaration. Use positional arguments instead.
          RUBY

          # TODO: It could be autocorrected, but it hasn't been implemented yet because it's a rare case.
          #
          #   enum :x, %i[foo bar]
          #   enum :y, %i[baz qux]
          #
          expect_no_corrections
        end
      end

      context 'with hash syntax' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum status: { active: 0, archived: 1 }, _prefix: true
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments in `status` enum declaration. Use positional arguments instead.
          RUBY

          expect_correction(<<~RUBY)
            enum :status, { active: 0, archived: 1 }, prefix: true
          RUBY
        end
      end

      context 'with options prefixed with `_`' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            enum :status, { active: 0, archived: 1 }, _prefix: true, _suffix: true
                                                                     ^^^^^^^ Enum defined with deprecated options in `status` enum declaration. Remove the `_` prefix.
                                                      ^^^^^^^ Enum defined with deprecated options in `status` enum declaration. Remove the `_` prefix.
          RUBY

          expect_correction(<<~RUBY)
            enum :status, { active: 0, archived: 1 }, prefix: true, suffix: true
          RUBY
        end
      end

      context 'when the enum name is a string' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum "status" => { active: 0, archived: 1 }
                             ^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments in `status` enum declaration. Use positional arguments instead.
          RUBY

          expect_correction(<<~RUBY)
            enum "status", { active: 0, archived: 1 }
          RUBY
        end
      end

      context 'when the enum name is not a literal' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum KEY => { active: 0, archived: 1 }
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments in `KEY` enum declaration. Use positional arguments instead.
          RUBY

          expect_correction(<<~RUBY)
            enum KEY, { active: 0, archived: 1 }
          RUBY
        end
      end

      context 'when the enum name is underscored' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum :_key => { active: 0, archived: 1 }, _prefix: true
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments in `_key` enum declaration. Use positional arguments instead.
          RUBY

          expect_correction(<<~RUBY)
            enum :_key, { active: 0, archived: 1 }, prefix: true
          RUBY
        end
      end

      context 'when the enum value is not a literal' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            enum key: %i[foo bar].map.with_index { |v, i| [v, i] }.to_h
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments in `key` enum declaration. Use positional arguments instead.
          RUBY

          expect_correction(<<~RUBY)
            enum :key, %i[foo bar].map.with_index { |v, i| [v, i] }.to_h
          RUBY
        end
      end

      it 'autocorrects' do
        expect_offense(<<~RUBY)
          enum status: { active: 0, archived: 1 }
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments in `status` enum declaration. Use positional arguments instead.
        RUBY

        expect_correction(<<~RUBY)
          enum :status, { active: 0, archived: 1 }
        RUBY
      end

      it 'autocorrects options too' do
        expect_offense(<<~RUBY)
          enum status: { active: 0, archived: 1 }, _prefix: true, _suffix: true, _default: :active, _scopes: true, _instance_methods: true
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments in `status` enum declaration. Use positional arguments instead.
        RUBY

        expect_correction(<<~RUBY)
          enum :status, { active: 0, archived: 1 }, prefix: true, suffix: true, default: :active, scopes: true, instance_methods: true
        RUBY
      end
    end

    context 'when positional arguments are used' do
      it 'does not register an offense' do
        expect_no_offenses('enum :status, { active: 0, archived: 1 }, prefix: true')
      end
    end

    context 'when enum with no arguments' do
      it 'does not register an offense' do
        expect_no_offenses('enum')
      end
    end
  end

  context 'Rails >= 7.0 and Ruby <= 2.7', :rails70, :ruby27, unsupported_on: :prism do
    context 'when keyword arguments are used' do
      context 'with %i[] syntax' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            enum status: %i[active archived], _prefix: true
          RUBY
        end
      end
    end
  end

  context 'Rails <= 6.1', :rails61 do
    context 'when keyword arguments are used' do
      context 'with %i[] syntax' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            enum status: { active: 0, archived: 1 }, _prefix: true
          RUBY
        end
      end

      context 'with options prefixed with `_`' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            enum :status, { active: 0, archived: 1 }, _prefix: true, _suffix: true
          RUBY
        end
      end

      context 'when the enum name is a string' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            enum "status" => { active: 0, archived: 1 }
          RUBY
        end
      end

      context 'when the enum name is not a literal' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            enum KEY => { active: 0, archived: 1 }
          RUBY
        end
      end

      it 'autocorrects' do
        expect_no_offenses(<<~RUBY)
          enum status: { active: 0, archived: 1 }
        RUBY
      end

      it 'autocorrects options too' do
        expect_no_offenses(<<~RUBY)
          enum status: { active: 0, archived: 1 }, _prefix: true, _suffix: true
        RUBY
      end
    end
  end
end
