# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::WhereNot, :config do
  it 'registers an offense and corrects when using `!=` and anonymous placeholder' do
    expect_offense(<<~RUBY)
      User.where('name != ?', 'Gabe')
           ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: 'Gabe')` instead of manually constructing negated SQL in `where`.
    RUBY

    expect_correction(<<~RUBY)
      User.where.not(name: 'Gabe')
    RUBY
  end

  it 'registers an offense and corrects when using `!=` and anonymous placeholder with safe navigation' do
    expect_offense(<<~RUBY)
      User&.where('name != ?', 'Gabe')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where&.not(name: 'Gabe')` instead of manually constructing negated SQL in `where`.
    RUBY

    expect_correction(<<~RUBY)
      User&.where&.not(name: 'Gabe')
    RUBY
  end

  it 'registers an offense and corrects when using `!=` and named placeholder' do
    expect_offense(<<~RUBY)
      User.where('name != :name', name: 'Gabe')
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: 'Gabe')` instead of manually constructing negated SQL in `where`.
    RUBY

    expect_correction(<<~RUBY)
      User.where.not(name: 'Gabe')
    RUBY
  end

  it 'registers an offense and corrects when using `<>` and anonymous placeholder' do
    expect_offense(<<~RUBY)
      User.where('name <> ?', 'Gabe')
           ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: 'Gabe')` instead of manually constructing negated SQL in `where`.
    RUBY

    expect_correction(<<~RUBY)
      User.where.not(name: 'Gabe')
    RUBY
  end

  it 'registers an offense and corrects when using `<>` and named placeholder' do
    expect_offense(<<~RUBY)
      User.where('name <> :name', name: 'Gabe')
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: 'Gabe')` instead of manually constructing negated SQL in `where`.
    RUBY

    expect_correction(<<~RUBY)
      User.where.not(name: 'Gabe')
    RUBY
  end

  it 'registers an offense and corrects when using `IS NOT NULL`' do
    expect_offense(<<~RUBY)
      User.where('name IS NOT NULL')
           ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: nil)` instead of manually constructing negated SQL in `where`.
    RUBY

    expect_correction(<<~RUBY)
      User.where.not(name: nil)
    RUBY
  end

  it 'registers an offense and corrects when using `NOT IN` and anonymous placeholder' do
    expect_offense(<<~RUBY)
      User.where("name NOT IN (?)", ['john', 'jane'])
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: ['john', 'jane'])` instead of manually constructing negated SQL in `where`.
    RUBY

    expect_correction(<<~RUBY)
      User.where.not(name: ['john', 'jane'])
    RUBY
  end

  it 'registers an offense and corrects when using `NOT IN` and named placeholder' do
    expect_offense(<<~RUBY)
      User.where("name NOT IN (:names)", names: ['john', 'jane'])
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: ['john', 'jane'])` instead of manually constructing negated SQL in `where`.
    RUBY

    expect_correction(<<~RUBY)
      User.where.not(name: ['john', 'jane'])
    RUBY
  end

  it 'registers an offense and corrects when using `!=` and namespaced columns' do
    expect_offense(<<~RUBY)
      Course.where('enrollments.student_id != ?', student.id)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(enrollments: { student_id: student.id })` instead of manually constructing negated SQL in `where`.
    RUBY

    expect_correction(<<~RUBY)
      Course.where.not(enrollments: { student_id: student.id })
    RUBY
  end

  it 'registers an offense and corrects when using `<>` and namespaced columns' do
    expect_offense(<<~RUBY)
      Course.where('enrollments.student_id <> ?', student.id)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(enrollments: { student_id: student.id })` instead of manually constructing negated SQL in `where`.
    RUBY

    expect_correction(<<~RUBY)
      Course.where.not(enrollments: { student_id: student.id })
    RUBY
  end

  context 'with array arguments' do
    it 'registers an offense and corrects when using `!=` and anonymous placeholder' do
      expect_offense(<<~RUBY)
        User.where(['name != ?', 'Gabe'])
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: 'Gabe')` instead of manually constructing negated SQL in `where`.
      RUBY

      expect_correction(<<~RUBY)
        User.where.not(name: 'Gabe')
      RUBY
    end

    it 'registers an offense and corrects when using `!=` and anonymous placeholder with safe navigation' do
      expect_offense(<<~RUBY)
        User&.where(['name != ?', 'Gabe'])
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where&.not(name: 'Gabe')` instead of manually constructing negated SQL in `where`.
      RUBY

      expect_correction(<<~RUBY)
        User&.where&.not(name: 'Gabe')
      RUBY
    end

    it 'registers an offense and corrects when using `!=` and named placeholder' do
      expect_offense(<<~RUBY)
        User.where(['name != :name', { name: 'Gabe' }])
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: 'Gabe')` instead of manually constructing negated SQL in `where`.
      RUBY

      expect_correction(<<~RUBY)
        User.where.not(name: 'Gabe')
      RUBY
    end

    it 'registers an offense and corrects when using `<>` and anonymous placeholder' do
      expect_offense(<<~RUBY)
        User.where(['name <> ?', 'Gabe'])
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: 'Gabe')` instead of manually constructing negated SQL in `where`.
      RUBY

      expect_correction(<<~RUBY)
        User.where.not(name: 'Gabe')
      RUBY
    end

    it 'registers an offense and corrects when using `<>` and named placeholder' do
      expect_offense(<<~RUBY)
        User.where(['name <> :name', { name: 'Gabe' }])
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: 'Gabe')` instead of manually constructing negated SQL in `where`.
      RUBY

      expect_correction(<<~RUBY)
        User.where.not(name: 'Gabe')
      RUBY
    end

    it 'registers an offense and corrects when using `IS NOT NULL`' do
      expect_offense(<<~RUBY)
        User.where(['name IS NOT NULL'])
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: nil)` instead of manually constructing negated SQL in `where`.
      RUBY

      expect_correction(<<~RUBY)
        User.where.not(name: nil)
      RUBY
    end

    it 'registers an offense and corrects when using `NOT IN` and anonymous placeholder' do
      expect_offense(<<~RUBY)
        User.where(["name NOT IN (?)", ['john', 'jane']])
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: ['john', 'jane'])` instead of manually constructing negated SQL in `where`.
      RUBY

      expect_correction(<<~RUBY)
        User.where.not(name: ['john', 'jane'])
      RUBY
    end

    it 'registers an offense and corrects when using `NOT IN` and named placeholder' do
      expect_offense(<<~RUBY)
        User.where(["name NOT IN (:names)", names: ['john', 'jane']])
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(name: ['john', 'jane'])` instead of manually constructing negated SQL in `where`.
      RUBY

      expect_correction(<<~RUBY)
        User.where.not(name: ['john', 'jane'])
      RUBY
    end

    it 'registers an offense and corrects when using `!=` and namespaced columns' do
      expect_offense(<<~RUBY)
        Course.where(['enrollments.student_id != ?', student.id])
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(enrollments: { student_id: student.id })` instead of manually constructing negated SQL in `where`.
      RUBY

      expect_correction(<<~RUBY)
        Course.where.not(enrollments: { student_id: student.id })
      RUBY
    end

    it 'registers an offense and corrects when using `<>` and namespaced columns' do
      expect_offense(<<~RUBY)
        Course.where(['enrollments.student_id <> ?', student.id])
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `where.not(enrollments: { student_id: student.id })` instead of manually constructing negated SQL in `where`.
      RUBY

      expect_correction(<<~RUBY)
        Course.where.not(enrollments: { student_id: student.id })
      RUBY
    end
  end

  it 'does not register an offense when using `where.not`' do
    expect_no_offenses(<<~RUBY)
      User.where.not(name: nil)
    RUBY
  end

  it 'does not register an offense when not using template string' do
    expect_no_offenses(<<~RUBY)
      User.where(name: 'john')
    RUBY
  end

  it 'does not register an offense when template string does not contain negation' do
    expect_no_offenses(<<~RUBY)
      User.where('name = ?', 'john')
    RUBY
  end

  it 'does not register an offense when template string contains `!=` and additional boolean logic' do
    expect_no_offenses(<<~RUBY)
      User.where('name != ? AND age != ?', 'john', 19)
    RUBY
  end

  it 'does not register an offense when template string contains `<>` and additional boolean logic' do
    expect_no_offenses(<<~RUBY)
      User.where('name <> ? AND age <> ?', 'john', 19)
    RUBY
  end
end
