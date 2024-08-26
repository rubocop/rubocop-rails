# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::WhereEquals, :config do
  it 'registers an offense and corrects when using `=` and anonymous placeholder' do
    expect_offense(<<~RUBY)
      User.where('name = ?', 'Gabe')
           ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(name: 'Gabe')` instead of manually constructing SQL.
    RUBY

    expect_correction(<<~RUBY)
      User.where(name: 'Gabe')
    RUBY
  end

  it 'registers an offense and corrects when using `=` and anonymous placeholder with not' do
    expect_offense(<<~RUBY)
      User.where.not('name = ?', 'Gabe')
                 ^^^^^^^^^^^^^^^^^^^^^^^ Use `not(name: 'Gabe')` instead of manually constructing SQL.
    RUBY

    expect_correction(<<~RUBY)
      User.where.not(name: 'Gabe')
    RUBY
  end

  it 'registers an offense and corrects when using `=` and anonymous placeholder with safe navigation' do
    expect_offense(<<~RUBY)
      User&.where('name = ?', 'Gabe')
            ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(name: 'Gabe')` instead of manually constructing SQL.
    RUBY

    expect_correction(<<~RUBY)
      User&.where(name: 'Gabe')
    RUBY
  end

  it 'registers an offense and corrects when using `=` and named placeholder' do
    expect_offense(<<~RUBY)
      User.where('name = :name', name: 'Gabe')
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(name: 'Gabe')` instead of manually constructing SQL.
    RUBY

    expect_correction(<<~RUBY)
      User.where(name: 'Gabe')
    RUBY
  end

  it 'registers an offense and corrects when using `IS NULL`' do
    expect_offense(<<~RUBY)
      User.where('name IS NULL')
           ^^^^^^^^^^^^^^^^^^^^^ Use `where(name: nil)` instead of manually constructing SQL.
    RUBY

    expect_correction(<<~RUBY)
      User.where(name: nil)
    RUBY
  end

  it 'registers an offense and corrects when using `IN` and anonymous placeholder' do
    expect_offense(<<~RUBY)
      User.where("name IN (?)", ['john', 'jane'])
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(name: ['john', 'jane'])` instead of manually constructing SQL.
    RUBY

    expect_correction(<<~RUBY)
      User.where(name: ['john', 'jane'])
    RUBY
  end

  it 'registers an offense and corrects when using `IN` and named placeholder' do
    expect_offense(<<~RUBY)
      User.where("name IN (:names)", names: ['john', 'jane'])
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(name: ['john', 'jane'])` instead of manually constructing SQL.
    RUBY

    expect_correction(<<~RUBY)
      User.where(name: ['john', 'jane'])
    RUBY
  end

  it 'registers an offense and corrects when using `=` and namespaced columns' do
    expect_offense(<<~RUBY)
      Course.where('enrollments.student_id = ?', student.id)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(enrollments: { student_id: student.id })` instead of manually constructing SQL.
    RUBY

    expect_correction(<<~RUBY)
      Course.where(enrollments: { student_id: student.id })
    RUBY
  end

  context 'with array arguments' do
    it 'registers an offense and corrects when using `=` and anonymous placeholder' do
      expect_offense(<<~RUBY)
        User.where(['name = ?', 'Gabe'])
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(name: 'Gabe')` instead of manually constructing SQL.
      RUBY

      expect_correction(<<~RUBY)
        User.where(name: 'Gabe')
      RUBY
    end

    it 'registers an offense and corrects when using `=` and anonymous placeholder with safe navigation' do
      expect_offense(<<~RUBY)
        User&.where(['name = ?', 'Gabe'])
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(name: 'Gabe')` instead of manually constructing SQL.
      RUBY

      expect_correction(<<~RUBY)
        User&.where(name: 'Gabe')
      RUBY
    end

    it 'registers an offense and corrects when using `=` and named placeholder' do
      expect_offense(<<~RUBY)
        User.where(['name = :name', { name: 'Gabe' }])
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(name: 'Gabe')` instead of manually constructing SQL.
      RUBY

      expect_correction(<<~RUBY)
        User.where(name: 'Gabe')
      RUBY
    end

    it 'registers an offense and corrects when using `IS NULL`' do
      expect_offense(<<~RUBY)
        User.where(['name IS NULL'])
             ^^^^^^^^^^^^^^^^^^^^^^^ Use `where(name: nil)` instead of manually constructing SQL.
      RUBY

      expect_correction(<<~RUBY)
        User.where(name: nil)
      RUBY
    end

    it 'registers an offense and corrects when using `IN` and anonymous placeholder' do
      expect_offense(<<~RUBY)
        User.where(["name IN (?)", ['john', 'jane']])
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(name: ['john', 'jane'])` instead of manually constructing SQL.
      RUBY

      expect_correction(<<~RUBY)
        User.where(name: ['john', 'jane'])
      RUBY
    end

    it 'registers an offense and corrects when using `IN` and named placeholder' do
      expect_offense(<<~RUBY)
        User.where(["name IN (:names)", names: ['john', 'jane']])
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(name: ['john', 'jane'])` instead of manually constructing SQL.
      RUBY

      expect_correction(<<~RUBY)
        User.where(name: ['john', 'jane'])
      RUBY
    end

    it 'registers an offense and corrects when using `=` and namespaced columns' do
      expect_offense(<<~RUBY)
        Course.where(['enrollments.student_id = ?', student.id])
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where(enrollments: { student_id: student.id })` instead of manually constructing SQL.
      RUBY

      expect_correction(<<~RUBY)
        Course.where(enrollments: { student_id: student.id })
      RUBY
    end
  end

  it 'does not register an offense when using `where`' do
    expect_no_offenses(<<~RUBY)
      User.where(name: nil)
    RUBY
  end

  it 'does not register an offense when not using template string' do
    expect_no_offenses(<<~RUBY)
      User.where(name: 'john')
    RUBY
  end

  it 'does not register an offense when template string does contains negation' do
    expect_no_offenses(<<~RUBY)
      User.where('name != ?', 'john')
    RUBY
  end

  it 'does not register an offense when template string contains `=` and additional boolean logic' do
    expect_no_offenses(<<~RUBY)
      User.where('name = ? AND age = ?', 'john', 19)
    RUBY
  end

  it 'does not register an offense when using only named placeholder template without replacement argument' do
    expect_no_offenses(<<~'RUBY')
      sql = User.where('name = :name').select(:id).to_sql

      User.where("id IN (#{sql})", name: 'Lastname').first
    RUBY
  end

  it 'does not register an offense when using `=` and the second argument has no content' do
    expect_no_offenses(<<~RUBY)
      User.where('name = ?', )
    RUBY
  end

  it 'does not register an offense when using `IN` and the second argument has no content' do
    expect_no_offenses(<<~RUBY)
      User.where("name IN (:names)", )
    RUBY
  end

  it 'does not register an offense when using `not` not preceded by `where`' do
    expect_no_offenses(<<~RUBY)
      users.not('name = ?', 'Gabe')
    RUBY
  end

  it 'does not register an offense when qualifying the database' do
    expect_no_offenses(<<~RUBY)
      User.where('database.users.name = ?', 'Gabe')
    RUBY
  end
end
