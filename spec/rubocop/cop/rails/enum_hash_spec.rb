# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EnumHash do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when array syntax is used' do
    context 'with %i[] syntax' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: %i[active archived]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY
      end
    end

    context 'with %w[] syntax' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: %w[active archived]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY
      end
    end

    context 'with %i() syntax' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: %i(active archived)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY
      end
    end

    context 'with %w() syntax' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: %w(active archived)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY
      end
    end

    context 'with [] syntax' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: [:active, :archived]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY
      end
    end
  end

  context 'when hash syntax is used' do
    it 'does not register an offense' do
      expect_no_offenses('enum status: { active: 0, archived: 1 }')
    end
  end
end
