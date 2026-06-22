# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::BeforeDestroy, :config do
  ['class MyRecord < ApplicationRecord', 'module MyMixin'].each do |container|
    %w[belongs_to has_one has_many].freeze.each do |association_type|
      context "when inside a #{container.split.first}" do
        context "and #{association_type} is declared before before_destroy" do
          context 'and before_destroy uses a block' do
            it 'registers an offense' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy { do_something }
                  ^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy(prepend: true) { do_something }
                end
              RUBY
            end

            it 'does not register an offense if before_destroy with `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy(prepend: true) { do_something }
                end
              RUBY
            end

            it "registers an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy with `prepend: true`' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy(prepend: true) { do_something }
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy { do_something }
                end
              RUBY
            end

            it "does not register an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy without `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy { do_something }
                end
              RUBY
            end

            it 'does not register an offense if dependent has an option other than :destroy' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :nullify
                  before_destroy { do_something }
                end
              RUBY
            end

            it 'registers an offense if before_destroy uses a block with a condition' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy unless: :condition? do
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                    do_something
                  end
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy prepend: true, unless: :condition? do
                    do_something
                  end
                end
              RUBY
            end

            it 'registers an offense ' \
               "if a #{association_type} has both associations with and without `dependent: :destroy`" do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  #{association_type} :accounts
                  before_destroy { do_something }
                  ^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  #{association_type} :accounts
                  before_destroy(prepend: true) { do_something }
                end
              RUBY
            end
          end

          context 'and before_destroy references a method' do
            it 'registers an offense' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy :some_method
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy :some_method, prepend: true
                end
              RUBY
            end

            it 'does not register an offense if before_destroy with `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy :some_method, prepend: true
                end
              RUBY
            end

            it "registers an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy with `prepend: true`' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy :some_method, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy :some_method
                end
              RUBY
            end

            it "does not register an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy without `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy :some_method
                end
              RUBY
            end

            it 'does not register an offense if dependent has an option other than :destroy' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :nullify
                  before_destroy :some_method
                end
              RUBY
            end

            it 'registers an offense if before_destroy passes a method with a condition' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy :some_method, unless: :condition?
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy :some_method, prepend: true, unless: :condition?
                end
              RUBY
            end

            it 'registers an offense if before_destroy passes multiple methods' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy :some_method, :another_method
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy :some_method, :another_method, prepend: true
                end
              RUBY
            end

            it 'registers an offense ' \
               "if a #{association_type} has both associations with and without `dependent: :destroy`" do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  #{association_type} :accounts
                  before_destroy :some_method
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  #{association_type} :accounts
                  before_destroy :some_method, prepend: true
                end
              RUBY
            end
          end

          context 'and before_destroy is called with an instance of a class' do
            it 'registers an offense' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy MyClass.new
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy MyClass.new, prepend: true
                end
              RUBY
            end

            it 'does not register an offense if before_destroy with `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy MyClass.new, prepend: true
                end
              RUBY
            end

            it "registers an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy with `prepend: true`' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy MyClass.new, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy MyClass.new
                end
              RUBY
            end

            it "does not register an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy without `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy MyClass.new
                end
              RUBY
            end

            it 'does not register an offense if dependent has an option other than :destroy' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :nullify
                  before_destroy MyClass.new
                end
              RUBY
            end

            it 'registers an offense if before_destroy includes a condition' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy MyClass.new, unless: :condition?
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy MyClass.new, prepend: true, unless: :condition?
                end
              RUBY
            end

            it 'registers an offense if before_destroy passes multiple instances of classes' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy MyClass.new, AnotherClass.new
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy MyClass.new, AnotherClass.new, prepend: true
                end
              RUBY
            end

            it 'registers an offense ' \
               "if a #{association_type} has both associations with and without `dependent: :destroy`" do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  #{association_type} :accounts
                  before_destroy MyClass.new
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  #{association_type} :accounts
                  before_destroy MyClass.new, prepend: true
                end
              RUBY
            end
          end

          context 'and before_destroy references a lambda expression' do
            it 'registers an offense' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy -> { do_something }
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy -> { do_something }, prepend: true
                end
              RUBY
            end

            it 'does not register an offense if before_destroy with `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy -> { do_something }, prepend: true
                end
              RUBY
            end

            it "registers an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy with `prepend: true`' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy -> { do_something }, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy -> { do_something }
                end
              RUBY
            end

            it "does not register an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy without `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy -> { do_something }
                end
              RUBY
            end

            it 'does not register an offense if dependent has an option other than :destroy' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :nullify
                  before_destroy -> { do_something }
                end
              RUBY
            end

            it 'registers an offense if before_destroy includes a condition' do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy -> { do_something }, unless: :condition?
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy -> { do_something }, prepend: true, unless: :condition?
                end
              RUBY
            end

            it 'registers an offense ' \
               "if a #{association_type} has both associations with and without `dependent: :destroy`" do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  #{association_type} :accounts
                  before_destroy -> { do_something }
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  #{association_type} :accounts
                  before_destroy -> { do_something }, prepend: true
                end
              RUBY
            end
          end
        end

        context "and before_destroy is declared before #{association_type} with `dependent: :destroy`" do
          context 'and before_destroy uses a block' do
            it 'registers an offense' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy(prepend: true) { do_something }
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy { do_something }
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it 'does not register an offense if before_destroy without `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  before_destroy { do_something }
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it "registers an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy with `prepend: true`' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy(prepend: true) { do_something }
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy { do_something }
                  #{association_type} :entities
                end
              RUBY
            end

            it "does not register an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy without `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  before_destroy { do_something }
                  #{association_type} :entities
                end
              RUBY
            end

            it 'registers an offense if dependent has an option other than :destroy' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy(prepend: true) { do_something }
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :nullify
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy { do_something }
                  #{association_type} :entities, dependent: :nullify
                end
              RUBY
            end

            it 'registers an offense if before_destroy uses a block with a condition' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy prepend: true, unless: :condition? do
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                    do_something
                  end
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy  unless: :condition? do
                    do_something
                  end
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it 'does not register an offense ' \
               "if a #{association_type} has both associations with and without `dependent: :destroy`" do
              expect_no_offenses(<<~RUBY)
                #{container}
                  before_destroy do
                    do_something
                  end
                  #{association_type} :entities, dependent: :destroy
                  #{association_type} :accounts
                end
              RUBY
            end
          end

          context 'and before_destroy references a method' do
            it 'registers an offense' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy :some_method, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy :some_method
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it 'does not register an offense if before_destroy without `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  before_destroy :some_method
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it "registers an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy with `prepend: true`' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy :some_method, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy :some_method
                  #{association_type} :entities
                end
              RUBY
            end

            it "does not register an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy without `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  before_destroy :some_method
                  #{association_type} :entities
                end
              RUBY
            end

            it 'registers an offense if dependent has an option other than :destroy' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy :some_method, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :nullify
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy :some_method
                  #{association_type} :entities, dependent: :nullify
                end
              RUBY
            end

            it 'registers an offense if before_destroy passes a method with a condition' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy :some_method, prepend: true, unless: :condition?
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy :some_method, unless: :condition?
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it 'registers an offense if before_destroy passes multiple methods' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy :some_method, :another_method, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy :some_method, :another_method
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it 'does not register an offense ' \
               "if a #{association_type} has both associations with and without `dependent: :destroy`" do
              expect_no_offenses(<<~RUBY)
                #{container}
                  before_destroy :some_method
                  #{association_type} :entities, dependent: :destroy
                  #{association_type} :accounts
                end
              RUBY
            end
          end

          context 'and before_destroy is called with an instance of a class' do
            it 'registers an offense' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy MyClass.new, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy MyClass.new
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it 'does not register an offense if before_destroy without `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  before_destroy MyClass.new
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it "registers an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy with `prepend: true`' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy MyClass.new, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy MyClass.new
                  #{association_type} :entities
                end
              RUBY
            end

            it "does not register an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy without `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  before_destroy MyClass.new
                  #{association_type} :entities
                end
              RUBY
            end

            it 'registers an offense if dependent has an option other than :destroy' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy MyClass.new, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :nullify
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy MyClass.new
                  #{association_type} :entities, dependent: :nullify
                end
              RUBY
            end

            it 'registers an offense if before_destroy includes a condition' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy MyClass.new, prepend: true, unless: :condition?
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy MyClass.new, unless: :condition?
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it 'registers an offense if before_destroy passes multiple instances of classes' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy MyClass.new, AnotherClass.new, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy MyClass.new, AnotherClass.new
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it 'does not register an offense ' \
               "if a #{association_type} has both associations with and without `dependent: :destroy`" do
              expect_no_offenses(<<~RUBY)
                #{container}
                  before_destroy MyClass.new
                  #{association_type} :entities, dependent: :destroy
                  #{association_type} :accounts
                end
              RUBY
            end
          end

          context 'and before_destroy references a lambda expression' do
            it 'registers an offense' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy -> { do_something }, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy -> { do_something }
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it 'does not register an offense if before_destroy without `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  before_destroy -> { do_something }
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it "registers an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy with `prepend: true`' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy -> { do_something }, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy -> { do_something }
                  #{association_type} :entities
                end
              RUBY
            end

            it "does not register an offense if a #{association_type} does not use `dependent: :destroy` " \
               'and before_destroy without `prepend: true`' do
              expect_no_offenses(<<~RUBY)
                #{container}
                  before_destroy -> { do_something }
                  #{association_type} :entities
                end
              RUBY
            end

            it 'registers an offense if dependent has an option other than :destroy' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy -> { do_something }, prepend: true
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :nullify
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy -> { do_something }
                  #{association_type} :entities, dependent: :nullify
                end
              RUBY
            end

            it 'registers an offense if before_destroy includes a condition' do
              expect_offense(<<~RUBY)
                #{container}
                  before_destroy -> { do_something }, prepend: true, unless: :condition?
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  before_destroy -> { do_something }, unless: :condition?
                  #{association_type} :entities, dependent: :destroy
                end
              RUBY
            end

            it 'does not register an offense ' \
               "if a #{association_type} has both associations with and without `dependent: :destroy`" do
              expect_no_offenses(<<~RUBY)
                #{container}
                  before_destroy -> { do_something }
                  #{association_type} :entities, dependent: :destroy
                  #{association_type} :accounts
                end
              RUBY
            end
          end
        end

        context "and #{association_type} is declared around before_destroy" do
          context 'and before_destroy uses a block' do
            it "registers an offense when all #{association_type}'s have `dependent: :destroy`" do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy { do_something }
                  ^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :accounts, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy(prepend: true) { do_something }
                  #{association_type} :accounts, dependent: :destroy
                end
              RUBY
            end

            it "does not register an offense when no #{association_type}'s have `dependent: :destroy`" do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy { do_something }
                  #{association_type} :accounts
                end
              RUBY
            end

            it 'registers an offense ' \
               "when the first #{association_type} has `dependent: :destroy` and the second does not" do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy { do_something }
                  ^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :accounts
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy(prepend: true) { do_something }
                  #{association_type} :accounts
                end
              RUBY
            end

            it 'does not register an offense ' \
               "when the first #{association_type} does not have `dependent: :destroy` and the second does" do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy { do_something }
                  #{association_type} :accounts, dependent: :destroy
                end
              RUBY
            end
          end

          context 'and before_destroy references a method' do
            it "registers an offense when all #{association_type}'s have `dependent: :destroy`" do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy :some_method
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :accounts, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy :some_method, prepend: true
                  #{association_type} :accounts, dependent: :destroy
                end
              RUBY
            end

            it "does not register an offense when no #{association_type}'s have `dependent: :destroy`" do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy :some_method
                  #{association_type} :accounts
                end
              RUBY
            end

            it 'registers an offense ' \
               "when the first #{association_type} has `dependent: :destroy` and the second does not" do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy :some_method
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :accounts
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy :some_method, prepend: true
                  #{association_type} :accounts
                end
              RUBY
            end

            it 'does not register an offense ' \
               "when the first #{association_type} does not have `dependent: :destroy` and the second does" do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy :some_method
                  #{association_type} :accounts, dependent: :destroy
                end
              RUBY
            end
          end

          context 'and before_destroy is called with an instance of a class' do
            it "registers an offense when all #{association_type}'s have `dependent: :destroy`" do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy MyClass.new
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :accounts, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy MyClass.new, prepend: true
                  #{association_type} :accounts, dependent: :destroy
                end
              RUBY
            end

            it "does not register an offense when no #{association_type}'s have `dependent: :destroy`" do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy MyClass.new
                  #{association_type} :accounts
                end
              RUBY
            end

            it 'registers an offense ' \
               "when the first #{association_type} has `dependent: :destroy` and the second does not" do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy MyClass.new
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :accounts
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy MyClass.new, prepend: true
                  #{association_type} :accounts
                end
              RUBY
            end

            it 'does not register an offense ' \
               "when the first #{association_type} does not have `dependent: :destroy` and the second does" do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy MyClass.new
                  #{association_type} :accounts, dependent: :destroy
                end
              RUBY
            end
          end

          context 'and before_destroy references a lambda expression' do
            it "registers an offense when all #{association_type}'s have `dependent: :destroy`" do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy -> { do_something }
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :accounts, dependent: :destroy
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy -> { do_something }, prepend: true
                  #{association_type} :accounts, dependent: :destroy
                end
              RUBY
            end

            it "does not register an offense when no #{association_type}'s have `dependent: :destroy`" do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy -> { do_something }
                  #{association_type} :accounts
                end
              RUBY
            end

            it 'registers an offense ' \
               "when the first #{association_type} has `dependent: :destroy` and the second does not" do
              expect_offense(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy -> { do_something }
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ "before_destroy" callbacks must be declared before "dependent: :destroy" associations or use `prepend: true`.
                  #{association_type} :accounts
                end
              RUBY

              expect_correction(<<~RUBY)
                #{container}
                  #{association_type} :entities, dependent: :destroy
                  before_destroy -> { do_something }, prepend: true
                  #{association_type} :accounts
                end
              RUBY
            end

            it 'does not register an offense ' \
               "when the first #{association_type} does not have `dependent: :destroy` and the second does" do
              expect_no_offenses(<<~RUBY)
                #{container}
                  #{association_type} :entities
                  before_destroy -> { do_something }
                  #{association_type} :accounts, dependent: :destroy
                end
              RUBY
            end
          end
        end
      end
    end
  end
end
