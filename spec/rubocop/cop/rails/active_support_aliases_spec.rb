# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActiveSupportAliases do
  subject(:cop) { described_class.new }

  describe 'String' do
    describe '#starts_with?' do
      it 'is registered as an offence' do
        expect_offense(<<-RUBY.strip_indent)
          'some_string'.starts_with?('prefix')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `start_with?` instead of `starts_with?`.
        RUBY
      end

      it 'is autocorrected' do
        new_source = autocorrect_source(
          "'some_string'.starts_with?('prefix')"
        )
        expect(new_source).to eq "'some_string'.start_with?('prefix')"
      end
    end

    describe '#start_with?' do
      it 'is not registered as an offense' do
        expect_no_offenses("'some_string'.start_with?('prefix')")
      end
    end

    describe '#ends_with?' do
      it 'is registered as an offense' do
        expect_offense(<<-RUBY.strip_indent)
          'some_string'.ends_with?('prefix')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `end_with?` instead of `ends_with?`.
        RUBY
      end

      it 'is autocorrected' do
        new_source = autocorrect_source(
          "'some_string'.ends_with?('prefix')"
        )
        expect(new_source).to eq "'some_string'.end_with?('prefix')"
      end
    end

    describe '#end_with?' do
      it 'is not registered as an offense' do
        expect_no_offenses("'some_string'.end_with?('prefix')")
      end
    end
  end

  describe 'Array' do
    describe '#append' do
      it 'is registered as an offence' do
        expect_offense(<<-RUBY.strip_indent)
          [1, 'a', 3].append('element')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `<<` instead of `append`.
        RUBY
      end

      it 'is not autocorrected' do
        source = "[1, 'a', 3].append('element')"
        new_source = autocorrect_source(source)
        expect(new_source).to eq source
      end
    end

    describe '#<<' do
      it 'is not registered as an offense' do
        expect_no_offenses("[1, 'a', 3] << 'element'")
      end
    end

    describe '#prepend' do
      it 'is registered as an offence' do
        expect_offense(<<-RUBY.strip_indent)
          [1, 'a', 3].prepend('element')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `unshift` instead of `prepend`.
        RUBY
      end

      it 'is autocorrected' do
        new_source = autocorrect_source(
          "[1, 'a', 3].prepend('element')"
        )
        expect(new_source).to eq "[1, 'a', 3].unshift('element')"
      end
    end

    describe '#unshift' do
      it 'is not registered as an offense' do
        expect_no_offenses("[1, 'a', 3].unshift('element')")
      end
    end
  end
end
