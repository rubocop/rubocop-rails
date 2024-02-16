# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EnumKeywordArgs, :config do
  context 'when keyword arguments are used' do
    context 'with %i[] syntax' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: { active: 0, archived: 1 }, _prefix: true
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments found in `status` enum declaration. Use positional arguments instead.
        RUBY
      end
    end

    context 'with options prefixed with `_`' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum :status, { active: 0, archived: 1 }, _prefix: true, _suffix: true
                                                                   ^^^^^^^ Enum defined with deprecated options found in `status` enum declaration. Use options without the `_` prefix.
                                                    ^^^^^^^ Enum defined with deprecated options found in `status` enum declaration. Use options without the `_` prefix.
        RUBY
      end
    end

    context 'when the enum name is a string' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum "status" => { active: 0, archived: 1 }
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments found in `status` enum declaration. Use positional arguments instead.
        RUBY
      end
    end

    context 'when the enum name is not a literal' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum KEY => { active: 0, archived: 1 }
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments found in `KEY` enum declaration. Use positional arguments instead.
        RUBY
      end
    end

    it 'autocorrects' do
      expect_offense(<<~RUBY)
        enum status: { active: 0, archived: 1 }
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments found in `status` enum declaration. Use positional arguments instead.
      RUBY

      expect_correction(<<~RUBY)
        enum :status, { active: 0, archived: 1 }
      RUBY
    end

    it 'autocorrects options too' do
      expect_offense(<<~RUBY)
        enum status: { active: 0, archived: 1 }, _prefix: true, _suffix: true
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined with keyword arguments found in `status` enum declaration. Use positional arguments instead.
      RUBY

      expect_correction(<<~RUBY)
        enum :status, { active: 0, archived: 1 }, prefix: true, suffix: true
      RUBY
    end
  end

  context 'when positional arguments are used' do
    it 'does not register an offense' do
      expect_no_offenses('enum :status, { active: 0, archived: 1 }, prefix: true')
    end
  end
end
