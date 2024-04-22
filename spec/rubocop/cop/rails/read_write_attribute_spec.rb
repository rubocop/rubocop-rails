# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ReadWriteAttribute, :config do
  context 'read_attribute' do
    it 'registers an offense and corrects a symbol' do
      expect_offense(<<~RUBY)
        res = read_attribute(:test)
              ^^^^^^^^^^^^^^^^^^^^^ Prefer `self[:test]`.
      RUBY

      expect_correction(<<~RUBY)
        res = self[:test]
      RUBY
    end

    it 'registers an offense and corrects a string' do
      expect_offense(<<~RUBY)
        res = read_attribute('test')
              ^^^^^^^^^^^^^^^^^^^^^^ Prefer `self['test']`.
      RUBY

      expect_correction(<<~RUBY)
        res = self['test']
      RUBY
    end

    it 'does not register an offense when called from a method with the same name' do
      expect_no_offenses(<<~RUBY)
        def foo
          bar || read_attribute(:foo)
        end
      RUBY
    end

    it 'registers an offense when called from a method with a different name' do
      expect_offense(<<~RUBY)
        def foo
          bar || read_attribute(:baz)
                 ^^^^^^^^^^^^^^^^^^^^ Prefer `self[:baz]`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          bar || self[:baz]
        end
      RUBY
    end

    it 'autocorrects without parentheses' do
      expect_offense(<<~RUBY)
        res = read_attribute 'test'
              ^^^^^^^^^^^^^^^^^^^^^ Prefer `self['test']`.
      RUBY

      expect_correction(<<~RUBY)
        res = self['test']
      RUBY
    end

    it 'corrects an expression' do
      expect_offense(<<~RUBY)
        res = read_attribute('test_' + postfix)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `self['test_' + postfix]`.
      RUBY

      expect_correction(<<~RUBY)
        res = self['test_' + postfix]
      RUBY
    end

    it 'corrects multiline' do
      expect_offense(<<~RUBY)
        res = read_attribute(
              ^^^^^^^^^^^^^^^ Prefer `self[:attr]`.
        (
        'test_' + postfix
        ).to_sym
        )
      RUBY

      expect_correction(<<~RUBY)
        res = self[(
        'test_' + postfix
        ).to_sym]
      RUBY
    end

    it 'registers no offense with explicit receiver' do
      expect_no_offenses('res = object.read_attribute(:test)')
    end

    context 'when used within a method' do
      context 'when using variable for the attribute name' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            def do_the_read_from(column)
              read_attribute(column)
              ^^^^^^^^^^^^^^^^^^^^^^ Prefer `self[column]`.
            end
          RUBY

          expect_correction(<<~RUBY)
            def do_the_read_from(column)
              self[column]
            end
          RUBY
        end
      end

      context 'when using constant for the attribute name' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            def do_the_read
              read_attribute(ATTR_NAME)
              ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `self[ATTR_NAME]`.
            end
          RUBY

          expect_correction(<<~RUBY)
            def do_the_read
              self[ATTR_NAME]
            end
          RUBY
        end
      end
    end
  end

  context 'write_attribute' do
    context 'when using a symbol for the attribute' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          write_attribute(:test, val)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `self[:test] = val`.
        RUBY

        expect_correction(<<~RUBY)
          self[:test] = val
        RUBY
      end
    end

    context 'when used within a method' do
      context 'when using variable for the attribute name' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            def do_the_write_to(column)
              write_attribute(column, 'value')
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `self[column] = 'value'`.
            end
          RUBY

          expect_correction(<<~RUBY)
            def do_the_write_to(column)
              self[column] = 'value'
            end
          RUBY
        end
      end

      context 'when using constant for the attribute name' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            def do_the_write(value)
              write_attribute(ATTR_NAME, value)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `self[ATTR_NAME] = value`.
            end
          RUBY

          expect_correction(<<~RUBY)
            def do_the_write(value)
              self[ATTR_NAME] = value
            end
          RUBY
        end
      end
    end

    context 'when using a string for the attribute' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          write_attribute('attr', 'test')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `self['attr'] = 'test'`.
        RUBY

        expect_correction(<<~RUBY)
          self['attr'] = 'test'
        RUBY
      end
    end

    it 'registers an offense and corrects without parentheses' do
      expect_offense(<<~RUBY)
        write_attribute 'attr', 'test'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `self['attr'] = 'test'`.
      RUBY

      expect_correction(<<~RUBY)
        self['attr'] = 'test'
      RUBY
    end

    it 'does not register an offense when called from a method with the same name' do
      expect_no_offenses(<<~RUBY)
        def foo=(value)
          bar(value) || write_attribute(:foo, "baz")
        end
      RUBY
    end

    it 'registers an offense when called from a method with a different name' do
      expect_offense(<<~RUBY)
        def foo=(value)
          bar(value) || write_attribute(:baz, "baz")
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `self[:baz] = "baz"`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo=(value)
          bar(value) || self[:baz] = "baz"
        end
      RUBY
    end

    it 'corrects assignment with chained methods' do
      expect_offense(<<~RUBY)
        write_attribute(:attr, 'test_' + postfix)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `self[:attr] = 'test_' + postfix`.
      RUBY

      expect_correction(<<~RUBY)
        self[:attr] = 'test_' + postfix
      RUBY
    end

    it 'autocorrects multiline' do
      expect_offense(<<~RUBY)
        write_attribute(
        ^^^^^^^^^^^^^^^^ Prefer `self[:attr] = val`.
        :attr,
        (
        'test_' + postfix
        ).to_sym
        )
      RUBY

      expect_correction(<<~RUBY)
        self[:attr] = (
        'test_' + postfix
        ).to_sym
      RUBY
    end

    it 'registers no offense with explicit receiver' do
      expect_no_offenses('object.write_attribute(:test, val)')
    end
  end
end
