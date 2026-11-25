# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RedundantClassNames, :config do
  context 'Rails >= 6.1', :rails61 do
    it 'registers an offense when using `class_names` in the `class` option of a tag builder' do
      expect_offense(<<~RUBY)
        tag.div class: class_names('foo', 'bar': condition)
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use an array literal instead of a redundant `class_names` call.
      RUBY

      expect_correction(<<~RUBY)
        tag.div class: ['foo', 'bar': condition]
      RUBY
    end

    it 'registers an offense when using `class_names` in the `class` option of a tag helper' do
      expect_offense(<<~RUBY)
        link_to 'text', path, class: class_names('foo', 'bar': condition)
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use an array literal instead of a redundant `class_names` call.
      RUBY

      expect_correction(<<~RUBY)
        link_to 'text', path, class: ['foo', 'bar': condition]
      RUBY
    end

    it 'does not register an offense when the result of `class_names` is sent a message' do
      expect_no_offenses(<<~RUBY)
        tag.div class: class_names('foo', 'bar': condition).presence
      RUBY
    end

    it 'does not register an offense when `class_names` has a receiver' do
      expect_no_offenses(<<~RUBY)
        tag.div class: presenter.class_names('foo', 'bar': condition)
      RUBY
    end

    it 'does not register an offense for a `class` key nested in another option' do
      expect_no_offenses(<<~RUBY)
        tag.div data: { class: class_names('foo', 'bar': condition) }
      RUBY
    end

    it 'does not register an offense for a method that is not a tag helper' do
      expect_no_offenses(<<~RUBY)
        render 'card', class: class_names('foo', 'bar': condition)
      RUBY
    end
  end

  context 'Rails <= 6.0', :rails60 do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        tag.div class: class_names('foo', 'bar': condition)
      RUBY
    end
  end
end
