# frozen_string_literal: true

RSpec.describe(RuboCop::Cop::Rails::ZeitwerkFriendlyConstant, :config) do
  describe('Offending code') do
    it 'Adds an offense when module name does not match filename' do
      code = <<~RUBY
        module Bar
        ^^^^^^^^^^ Module name does not match filename.
        end
      RUBY
      expect_offense(code, '/some/dir/foo.rb')
    end

    it 'Adds an offense when any of multiple module names does not match filename' do
      code = <<~RUBY
        module Foo
        end

        module Bar
        ^^^^^^^^^^ Module name does not match filename.
        end
      RUBY
      expect_offense(code, '/some/dir/foo.rb')
    end

    it 'Adds an offense when nested class or module name does not match filename path' do
      code = <<~RUBY
        class Foo
          module Bar
          ^^^^^^^^^^ Module name does not match filename.
          end
        end
      RUBY
      expect_offense(code, '/some/dir/bar.rb')
    end

    it 'Adds offenses to multiple constants that do not match filename' do
      code = <<~RUBY
        class Foo
          module Bar
          ^^^^^^^^^^ Module name does not match filename.
          end

          module Baz
          ^^^^^^^^^^ Module name does not match filename.
          end
        end
      RUBY
      expect_offense(code, '/some/dir/foo/qux.rb')
    end

    it 'Adds an offense when nested class or module name in compact form does not match filename path' do
      code = <<~RUBY
        class Foo::Bar
        ^^^^^^^^^^^^^^ Class name does not match filename.
        end
      RUBY
      expect_offense(code, '/some/dir/bar.rb')
    end

    it 'Adds an offense when parent namespace does not match defined module path' do
      code = <<~RUBY
        module Foo
          class Baz
          end

          module Bar
          ^^^^^^^^^^ Module name does not match filename.
          end
        end
      RUBY
      expect_offense(code, '/some/dir/foo/baz.rb')
    end

    it 'Adds an offense when namespace does not completely match module name' do
      code = <<~RUBY
        module Foo
          class Bar
          ^^^^^^^^^ Class name does not match filename.
          end
        end
      RUBY
      expect_offense(code, '/some/dir/foo/barbaz.rb')
    end

    it 'Adds an offense for constants that are neither modules nor classes' do
      code = <<~RUBY
        module Foo
          Bar = "mystring"
          ^^^^^^^^^^^^^^^^ Constant name does not match filename.
        end
      RUBY
      expect_offense(code, '/some/dir/foo/baz.rb')
    end

    it 'Adds an offense for constant nested inside block that does not match filename' do
      code = <<~RUBY
        module Foo
          begin
            module Baz
            ^^^^^^^^^^ Module name does not match filename.
            end
          end
        end
      RUBY
      expect_offense(code, '/some/dir/foo/bar.rb')
    end

    it 'Adds an offense for constants that have no common path' do
      code = <<~RUBY
        module Foo
        end

        module Bar
          module Foo
          ^^^^^^^^^^ Constant names are mutually incompatible with file path.
          end
        end
      RUBY
      expect_offense(code, '/some/dir/bar/foo.rb')
    end

    it 'Adds only one offense for constants that have no common path if one is already flagged' do
      code = <<~RUBY
        module Foo
        ^^^^^^^^^^ Module name does not match filename.
        end

        module Bar
        end
      RUBY
      expect_offense(code, '/some/dir/bar.rb')
    end
  end

  describe('Non offending code') do
    it 'Does not add an offense when module name matches filename' do
      code = <<~RUBY
        module Foo
        end
      RUBY
      expect_no_offenses(code, '/some/dir/foo.rb')
    end

    it 'Does not add an offense when nested module name matches filename path' do
      code = <<~RUBY
        module Foo
          module Bar
          end
        end
      RUBY
      expect_no_offenses(code, '/some/dir/foo/bar.rb')
    end

    it 'Does not add an offense when nested module name in compact form matches filename path' do
      code = <<~RUBY
        module Foo::Bar
        end
      RUBY
      expect_no_offenses(code, '/some/dir/foo/bar.rb')
    end

    it 'Does not add an offense when nested module name matches parent path' do
      code = <<~RUBY
        module Foo
          module Bar
          end
        end
      RUBY
      expect_no_offenses(code, '/some/dir/foo.rb')
    end

    it 'Does not add an offense for capitalized constants that match file name' do
      code = <<~RUBY
        module Foo
          MY_VERSION_STRING = "mystring"
        end
      RUBY
      expect_no_offenses(code, '/some/dir/foo/my_version_string.rb')
    end

    it 'Does not add an offense when multiple nested module names matches parent path' do
      code = <<~RUBY
        module Foo
          module Bar
          end

          class Baz
          end
        end
      RUBY
      expect_no_offenses(code, '/some/dir/foo.rb')
    end

    it 'Does not add an offense for more complex module names that match path' do
      code = <<~RUBY
        module FooBarBaz
        end
      RUBY
      expect_no_offenses(code, '/some/dir/foo_bar_baz.rb')
    end

    it 'Does not add an offense for file names with extra underscores' do
      code = <<~RUBY
        module FooBarBaz3
        end
      RUBY
      expect_no_offenses(code, '/some/dir/foo_bar_baz_3.rb')
    end

    it 'Does not add an offense when filename matches namespace in multiple places' do
      code = <<~RUBY
        module Foo
          module Bar
          end
        end
      RUBY
      expect_no_offenses(code, '/some/dir/foo/baz/foo/bar.rb')
    end

    it 'Does not add an offense for constants nested inside block that matches filename' do
      code = <<~RUBY
        module Foo
          begin
            module Bar
            end
          end
        end
      RUBY
      expect_no_offenses(code, '/some/dir/foo/bar.rb')
    end

    it 'Does not add an offense for non-Ruby files' do
      code = <<~RUBY
        module Foo
        end
      RUBY
      expect_no_offenses(code, '/some/dir/bar')
    end
  end

  describe('when config defines custom acronyms') do
    let(:cop_config) { { 'Acronyms' => ['GCS'] } }

    it 'Does not add an offense when filename matches constant with custom acronym' do
      code = <<~RUBY
        module GCSCsvCollection
          module Foo
          end
        end
      RUBY
      expect_no_offenses(code, '/some/dir/gcs_csv_collection/foo.rb')
    end
  end
end
