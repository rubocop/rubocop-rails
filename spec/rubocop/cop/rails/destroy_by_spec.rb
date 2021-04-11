# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DestroyBy, :config do
  context 'Rails >= 6.0', :rails60 do
    it 'registers and corrects an offense when using `find_by&.destroy`' do
      expect_offense(<<~RUBY)
        unreads.find_by(readable: readable)&.destroy
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `destroy_by(readable: readable)` instead.
      RUBY

      expect_correction(<<~RUBY)
        unreads.destroy_by(readable: readable)
      RUBY
    end

    it 'registers and corrects an offense when using `where.destroy_all`' do
      expect_offense(<<~RUBY)
        unreads.where(readable: readable).destroy_all
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `destroy_by(readable: readable)` instead.
      RUBY

      expect_correction(<<~RUBY)
        unreads.destroy_by(readable: readable)
      RUBY
    end

    it 'registers and corrects an offense when using `find_by.destroy`' do
      expect_offense(<<~RUBY)
        unreads.find_by(readable: readable).destroy
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `destroy_by(readable: readable)` instead.
      RUBY

      expect_correction(<<~RUBY)
        unreads.destroy_by(readable: readable)
      RUBY
    end

    it 'registers and corrects an offense when using `where&.destroy_all`' do
      expect_offense(<<~RUBY)
        unreads.where(readable: readable)&.destroy_all
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `destroy_by(readable: readable)` instead.
      RUBY

      expect_correction(<<~RUBY)
        unreads.destroy_by(readable: readable)
      RUBY
    end

    it 'registers and corrects an offense when using `where&.destroy_all` with multiple arguments' do
      expect_offense(<<~RUBY)
        model.where(foo: foo, bar: bar)&.destroy_all
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `destroy_by(foo: foo, bar: bar)` instead.
      RUBY

      expect_correction(<<~RUBY)
        model.destroy_by(foo: foo, bar: bar)
      RUBY
    end

    it 'does not register an offense when using `destroy_by`' do
      expect_no_offenses(<<~RUBY)
        unreads.destroy_by(readable: readable)
      RUBY
    end

    it 'does not register an offense when using `do_something.destroy`' do
      expect_no_offenses(<<~RUBY)
        unreads.do_something(readable: readable).destroy
      RUBY
    end

    it 'does not register an offense when using `do_something.destroy_all`' do
      expect_no_offenses(<<~RUBY)
        unreads.do_something(readable: readable).destroy_all
      RUBY
    end

    it 'does not register an offense when using `model.destroy`' do
      expect_no_offenses(<<~RUBY)
        model = Model.first
        model.destroy
      RUBY
    end

    it 'does not register an offense when using `destroy`' do
      expect_no_offenses(<<~RUBY)
        destroy
      RUBY
    end
  end

  context 'Rails <= 5.2', :rails52 do
    it 'does not register an offense when using `find_by&.destroy`' do
      expect_no_offenses(<<~RUBY)
        unreads.find_by(readable: readable)&.destroy
      RUBY
    end

    it 'does not register an offense when using `where.destroy_all`' do
      expect_no_offenses(<<~RUBY)
        unreads.where(readable: readable).destroy_all
      RUBY
    end

    it 'does not register an offense when using `find_by.destroy`' do
      expect_no_offenses(<<~RUBY)
        unreads.find_by(readable: readable).destroy
      RUBY
    end

    it 'does not register an offense when using `where&.destroy_all`' do
      expect_no_offenses(<<~RUBY)
        unreads.where(readable: readable)&.destroy_all
      RUBY
    end
  end
end
