# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DeleteBy, :config do
  context 'Rails >= 6.0', :rails60 do
    it 'registers and corrects an offense when using `find_by&.delete`' do
      expect_offense(<<~RUBY)
        unreads.find_by(readable: readable)&.delete
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `delete_by(readable: readable)` instead.
      RUBY

      expect_correction(<<~RUBY)
        unreads.delete_by(readable: readable)
      RUBY
    end

    it 'registers and corrects an offense when using `where.delete_all`' do
      expect_offense(<<~RUBY)
        unreads.where(readable: readable).delete_all
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `delete_by(readable: readable)` instead.
      RUBY

      expect_correction(<<~RUBY)
        unreads.delete_by(readable: readable)
      RUBY
    end

    it 'registers and corrects an offense when using `find_by.delete`' do
      expect_offense(<<~RUBY)
        unreads.find_by(readable: readable).delete
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `delete_by(readable: readable)` instead.
      RUBY

      expect_correction(<<~RUBY)
        unreads.delete_by(readable: readable)
      RUBY
    end

    it 'registers and corrects an offense when using `where&.delete_all`' do
      expect_offense(<<~RUBY)
        unreads.where(readable: readable)&.delete_all
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `delete_by(readable: readable)` instead.
      RUBY

      expect_correction(<<~RUBY)
        unreads.delete_by(readable: readable)
      RUBY
    end

    it 'registers and corrects an offense when using `where&.delete_all` with multiple arguments' do
      expect_offense(<<~RUBY)
        model.where(foo: foo, bar: bar)&.delete_all
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `delete_by(foo: foo, bar: bar)` instead.
      RUBY

      expect_correction(<<~RUBY)
        model.delete_by(foo: foo, bar: bar)
      RUBY
    end

    it 'does not register an offense when using `delete_by`' do
      expect_no_offenses(<<~RUBY)
        unreads.delete_by(readable: readable)
      RUBY
    end

    it 'does not register an offense when using `do_something.delete`' do
      expect_no_offenses(<<~RUBY)
        unreads.do_something(readable: readable).delete
      RUBY
    end

    it 'does not register an offense when using `do_something.delete_all`' do
      expect_no_offenses(<<~RUBY)
        unreads.do_something(readable: readable).delete_all
      RUBY
    end

    it 'does not register an offense when using `model.delete`' do
      expect_no_offenses(<<~RUBY)
        model = Model.first
        model.delete
      RUBY
    end

    it 'does not register an offense when using `delete`' do
      expect_no_offenses(<<~RUBY)
        delete
      RUBY
    end
  end

  context 'Rails <= 5.2', :rails52 do
    it 'does not register an offense when using `find_by&.delete`' do
      expect_no_offenses(<<~RUBY)
        unreads.find_by(readable: readable)&.delete
      RUBY
    end

    it 'does not register an offense when using `where.delete_all`' do
      expect_no_offenses(<<~RUBY)
        unreads.where(readable: readable).delete_all
      RUBY
    end

    it 'does not register an offense when using `find_by.delete`' do
      expect_no_offenses(<<~RUBY)
        unreads.find_by(readable: readable).delete
      RUBY
    end

    it 'does not register an offense when using `where&.delete_all`' do
      expect_no_offenses(<<~RUBY)
        unreads.where(readable: readable)&.delete_all
      RUBY
    end
  end
end
