# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::WhereExists, :config do
  context 'when EnforcedStyle is "exists"' do
    let(:cop_config) { { 'EnforcedStyle' => 'exists' } }

    it 'registers an offense and corrects when using `where(...).exists?` with hash argument' do
      expect_offense(<<~RUBY)
        User.where(name: 'john').exists?
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `exists?(name: 'john')` over `where(name: 'john').exists?`.
      RUBY

      expect_correction(<<~RUBY)
        User.exists?(name: 'john')
      RUBY
    end

    it 'registers an offense and corrects when using `where(...)&.exists?` with hash argument' do
      expect_offense(<<~RUBY)
        User.where(name: 'john')&.exists?
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `exists?(name: 'john')` over `where(name: 'john')&.exists?`.
      RUBY

      expect_correction(<<~RUBY)
        User.exists?(name: 'john')
      RUBY
    end

    it 'registers an offense and corrects when using `where(...)&.exists?` with hash argument with safe navigation' do
      expect_offense(<<~RUBY)
        User&.where(name: 'john')&.exists?
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `exists?(name: 'john')` over `where(name: 'john')&.exists?`.
      RUBY

      expect_correction(<<~RUBY)
        User&.exists?(name: 'john')
      RUBY
    end

    it 'registers an offense and corrects when using `where(...).exists?` with array argument' do
      expect_offense(<<~RUBY)
        User.where(['name = ?', 'john']).exists?
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `exists?(['name = ?', 'john'])` over `where(['name = ?', 'john']).exists?`.
      RUBY

      expect_correction(<<~RUBY)
        User.exists?(['name = ?', 'john'])
      RUBY
    end

    it 'registers an offense and corrects when using `where(...).exists?` with multiple arguments' do
      expect_offense(<<~RUBY)
        User.where('name = ?', 'john').exists?
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `exists?(['name = ?', 'john'])` over `where('name = ?', 'john').exists?`.
      RUBY

      expect_correction(<<~RUBY)
        User.exists?(['name = ?', 'john'])
      RUBY
    end

    # FIXME: `undefined method `[]' for nil` occurs Prism 0.24.0. It has been resolved in
    # the development line. This will be resolved in Prism > 0.24.0 and higher releases.
    it 'registers an offense when using implicit receiver and arg', broken_on: :prism do
      expect_offense(<<~RUBY)
        where('name = ?', 'john').exists?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `exists?(['name = ?', 'john'])` over `where('name = ?', 'john').exists?`.
      RUBY

      expect_correction(<<~RUBY)
        exists?(['name = ?', 'john'])
      RUBY
    end

    it 'registers an offense when using `where(...).exists?` with an association' do
      expect_offense(<<~RUBY)
        user.posts.where(published: true).exists?
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `exists?(published: true)` over `where(published: true).exists?`.
      RUBY

      expect_correction(<<~RUBY)
        user.posts.exists?(published: true)
      RUBY
    end

    it 'does not register an offense when using `where(...).exists?` with string argument' do
      expect_no_offenses(<<~RUBY)
        User.where("name = 'john'").exists?
      RUBY
    end

    it 'does not register an offense when using `exists?`' do
      expect_no_offenses(<<~RUBY)
        User.exists?(name: 'john')
      RUBY
    end

    it 'does not register an offense when using `exists?` with no args' do
      expect_no_offenses(<<~RUBY)
        User.exists?
      RUBY
    end

    it 'does not register an offense when using `exists?` with an association' do
      expect_no_offenses(<<~RUBY)
        user.posts.exists?(published: true)
      RUBY
    end
  end

  context 'when EnforcedStyle is "where"' do
    let(:cop_config) { { 'EnforcedStyle' => 'where' } }

    it 'registers an offense and corrects when using `exists?` with a hash' do
      expect_offense(<<~RUBY)
        User.exists?(name: 'john')
             ^^^^^^^^^^^^^^^^^^^^^ Prefer `where(name: 'john').exists?` over `exists?(name: 'john')`.
      RUBY

      expect_correction(<<~RUBY)
        User.where(name: 'john').exists?
      RUBY
    end

    it 'registers an offense and corrects when using `exists?` with a hash with safe navigation' do
      expect_offense(<<~RUBY)
        User&.exists?(name: 'john')
              ^^^^^^^^^^^^^^^^^^^^^ Prefer `where(name: 'john')&.exists?` over `exists?(name: 'john')`.
      RUBY

      expect_correction(<<~RUBY)
        User&.where(name: 'john')&.exists?
      RUBY
    end

    it 'registers an offense and corrects when using `exists?` with an array' do
      expect_offense(<<~RUBY)
        User.exists?(['name = ?', 'john'])
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `where(['name = ?', 'john']).exists?` over `exists?(['name = ?', 'john'])`.
      RUBY

      expect_correction(<<~RUBY)
        User.where(['name = ?', 'john']).exists?
      RUBY
    end

    it 'registers an offense and corrects when using `exists?` with an multiple arguments' do
      expect_offense(<<~RUBY)
        User.exists?('name = ?', 'john')
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `where('name = ?', 'john').exists?` over `exists?('name = ?', 'john')`.
      RUBY

      expect_correction(<<~RUBY)
        User.where('name = ?', 'john').exists?
      RUBY
    end

    # FIXME: `undefined method `[]' for nil` occurs Prism 0.24.0. It has been resolved in
    # the development line. This will be resolved in Prism > 0.24.0 and higher releases.
    it 'registers an offense when using implicit receiver and arg', broken_on: :prism do
      expect_offense(<<~RUBY)
        exists?('name = ?', 'john')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `where('name = ?', 'john').exists?` over `exists?('name = ?', 'john')`.
      RUBY

      expect_correction(<<~RUBY)
        where('name = ?', 'john').exists?
      RUBY
    end

    it 'registers an offense and corrects when using `exists?` with an association' do
      expect_offense(<<~RUBY)
        user.posts.exists?(published: true)
                   ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `where(published: true).exists?` over `exists?(published: true)`.
      RUBY

      expect_correction(<<~RUBY)
        user.posts.where(published: true).exists?
      RUBY
    end

    it 'does not register an offense when using `where(...).exists?` with hash argument' do
      expect_no_offenses(<<~RUBY)
        User.where(name: 'john').exists?
      RUBY
    end

    it 'does not register an offense when using `where(...).exists?` with array argument' do
      expect_no_offenses(<<~RUBY)
        User.where(['name = ?', 'john']).exists?
      RUBY
    end

    it 'does not register an offense when using `where(...).exists?` with multiple arguments' do
      expect_no_offenses(<<~RUBY)
        User.where('name = ?', 'john').exists?
      RUBY
    end

    it 'does not register an offense when using `where(...).exists?` with string argument' do
      expect_no_offenses(<<~RUBY)
        User.where("name = 'john'").exists?
      RUBY
    end

    it 'does not register an offense when using `where(...).exists?` with an association' do
      expect_no_offenses(<<~RUBY)
        user.posts.where(published: true).exists?
      RUBY
    end

    it 'does not register an offense when using `exists?` with no args' do
      expect_no_offenses(<<~RUBY)
        User.exists?
      RUBY
    end
  end
end
