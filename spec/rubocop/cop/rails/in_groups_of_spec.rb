# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::InGroupsOf, :config do
  context 'when EnforcedStyle is `each_slice`' do
    let(:cop_config) { { 'EnforcedStyle' => 'each_slice' } }

    it 'registers an offense when the second argument is absent' do
      expect_offense(<<~RUBY)
        collection.in_groups_of(3)
                   ^^^^^^^^^^^^ Use `each_slice` instead of `in_groups_of` to avoid padding groups with `nil`.
      RUBY
    end

    it 'registers an offense when the second argument is explicitly `false`' do
      expect_offense(<<~RUBY)
        collection.in_groups_of(3, false)
                   ^^^^^^^^^^^^ Prefer `each_slice` instead of `in_groups_of(..., false)` for clarity and simplicity.
      RUBY
    end

    it 'registers an offense when a block is passed and the second argument is absent' do
      expect_offense(<<~RUBY)
        collection.in_groups_of(3) { |group| do_something(group) }
                   ^^^^^^^^^^^^ Use `each_slice` instead of `in_groups_of` to avoid padding groups with `nil`.
      RUBY
    end

    it 'does not register an offense when the second argument is an explicit fill value' do
      expect_no_offenses(<<~RUBY)
        collection.in_groups_of(3, 0)
      RUBY
    end

    it 'does not register an offense when the second argument is an explicit `nil`' do
      expect_no_offenses(<<~RUBY)
        collection.in_groups_of(3, nil)
      RUBY
    end

    it 'does not register an offense when the second argument is a variable' do
      expect_no_offenses(<<~RUBY)
        collection.in_groups_of(3, fill)
      RUBY
    end

    it 'does not register an offense when there are no arguments' do
      expect_no_offenses(<<~RUBY)
        collection.in_groups_of
      RUBY
    end
  end

  context 'when EnforcedStyle is `explicit`' do
    let(:cop_config) { { 'EnforcedStyle' => 'explicit' } }

    it 'registers an offense suggesting an explicit second argument when it is absent' do
      expect_offense(<<~RUBY)
        collection.in_groups_of(3)
                   ^^^^^^^^^^^^ Specify an explicit second argument to `in_groups_of` to make padding behavior explicit.
      RUBY
    end

    it 'does not register an offense when the second argument is explicitly `false`' do
      expect_no_offenses(<<~RUBY)
        collection.in_groups_of(3, false)
      RUBY
    end

    it 'does not register an offense when the second argument is an explicit fill value' do
      expect_no_offenses(<<~RUBY)
        collection.in_groups_of(3, 0)
      RUBY
    end

    it 'does not register an offense when the second argument is an explicit `nil`' do
      expect_no_offenses(<<~RUBY)
        collection.in_groups_of(3, nil)
      RUBY
    end
  end
end
