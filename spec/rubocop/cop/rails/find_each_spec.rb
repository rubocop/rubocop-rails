# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::FindEach, :config do
  shared_examples 'register_offense' do |scope|
    it "registers an offense when using #{scope}.each" do
      expect_offense(<<~RUBY, scope: scope)
        User.#{scope}.each { |u| u.something }
             _{scope} ^^^^ Use `find_each` instead of `each`.
      RUBY
    end

    it "does not register an offense when using #{scope}.order(...).each" do
      expect_no_offenses("User.#{scope}.order(:name).each { |u| u.something }")
    end

    it "does not register an offense when using #{scope}.limit(...).each" do
      expect_no_offenses("User.#{scope}.limit(10).each { |u| u.something }")
    end

    it "does not register an offense when using #{scope}.select(...).each" do
      expect_no_offenses("User.#{scope}.select(:name, :age).each { |u| u.something }")
    end
  end

  it_behaves_like('register_offense', 'all')
  it_behaves_like('register_offense', 'eager_load(:association_name)')
  it_behaves_like('register_offense', 'includes(:association_name)')
  it_behaves_like('register_offense', 'joins(:association_name)')
  it_behaves_like('register_offense', 'left_joins(:association_name)')
  it_behaves_like('register_offense', 'left_outer_joins(:association_name)')
  it_behaves_like('register_offense', 'where(name: name).or(User.where(age: age))')
  it_behaves_like('register_offense', 'preload(:association_name)')
  it_behaves_like('register_offense', 'references(:association_name)')
  it_behaves_like('register_offense', 'unscoped')
  it_behaves_like('register_offense', 'where(name: name)')
  it_behaves_like('register_offense', 'where.not(name: name)')

  it 'does not register an offense when called on a constant' do
    expect_no_offenses('FOO.each { |u| u.x }')
  end

  it 'does not register an offense when using find_by' do
    expect_no_offenses('User.all.find_each { |u| u.x }')
  end

  # Active Model Errors slice from the new query interface introduced in Rails 6.1.
  it 'does not register an offense when using `model.errors.where`' do
    expect_no_offenses(<<~RUBY)
      class Model < ApplicationRecord
        model.errors.where(:title).each { |error| do_something(error)  }
      end
    RUBY
  end

  it 'registers an offense when using `where` with no receiver' do
    expect_offense(<<~RUBY)
      class Model < ApplicationRecord
        where(record: [record1, record2]).each(&:touch)
                                          ^^^^ Use `find_each` instead of `each`.
      end
    RUBY
  end

  it 'autocorrects each to find_each' do
    expect_offense(<<~RUBY)
      User.all.each { |u| u.x }
               ^^^^ Use `find_each` instead of `each`.
    RUBY

    expect_correction(<<~RUBY)
      User.all.find_each { |u| u.x }
    RUBY
  end

  it 'registers an offense with non-send ancestors' do
    expect_offense(<<~RUBY)
      class C; User.all.each { |u| u.x }; end
                        ^^^^ Use `find_each` instead of `each`.
    RUBY

    expect_correction(<<~RUBY)
      class C; User.all.find_each { |u| u.x }; end
    RUBY
  end

  context 'with no receiver' do
    it 'does not register an offense when not inheriting any class' do
      expect_no_offenses(<<~RUBY)
        class C
          all.each { |u| u.x }
        end
      RUBY
    end

    it 'does not register an offense when not inheriting `ApplicationRecord`' do
      expect_no_offenses(<<~RUBY)
        class C < Foo
          all.each { |u| u.x }
        end
      RUBY
    end

    it 'registers an offense when inheriting `ApplicationRecord`' do
      expect_offense(<<~RUBY)
        class C < ApplicationRecord
          all.each { |u| u.x }
              ^^^^ Use `find_each` instead of `each`.
        end
      RUBY
    end

    it 'registers an offense when inheriting `::ApplicationRecord`' do
      expect_offense(<<~RUBY)
        class C < ::ApplicationRecord
          all.each { |u| u.x }
              ^^^^ Use `find_each` instead of `each`.
        end
      RUBY
    end

    it 'registers an offense when inheriting `ActiveRecord::Base`' do
      expect_offense(<<~RUBY)
        class C < ActiveRecord::Base
          all.each { |u| u.x }
              ^^^^ Use `find_each` instead of `each`.
        end
      RUBY
    end

    it 'registers an offense when inheriting `::ActiveRecord::Base`' do
      expect_offense(<<~RUBY)
        class C < ::ActiveRecord::Base
          all.each { |u| u.x }
              ^^^^ Use `find_each` instead of `each`.
        end
      RUBY
    end
  end

  context 'allowed methods' do
    let(:cop_config) { { 'AllowedMethods' => %w[order lock], 'AllowedPatterns' => [], 'IgnoredMethods' => [] } }

    it 'does not register an offense when using order(...) earlier' do
      expect_no_offenses('User.order(:name).each { |u| u.something }')
    end

    it 'does not register an offense when using order(...) chained with other things' do
      expect_no_offenses('User.order(:name).includes(:company).each { |u| u.something }')
    end

    it 'does not register an offense when using lock earlier' do
      expect_no_offenses('User.lock.each { |u| u.something }')
    end

    it 'registers offense for methods not in `AllowedMethods`' do
      expect_offense(<<~RUBY)
        User.joins(:posts).each { |u| u.something }
                           ^^^^ Use `find_each` instead of `each`.
      RUBY
    end
  end

  context 'allowed patterns' do
    let(:cop_config) { { 'AllowedMethods' => [], 'AllowedPatterns' => %w[order lock], 'IgnoredMethods' => [] } }

    it 'does not register an offense when using order(...) earlier' do
      expect_no_offenses('User.order(:name).each { |u| u.something }')
    end

    it 'does not register an offense when using order(...) chained with other things' do
      expect_no_offenses('User.order(:name).includes(:company).each { |u| u.something }')
    end

    it 'does not register an offense when using lock earlier' do
      expect_no_offenses('User.lock.each { |u| u.something }')
    end

    it 'registers offense for methods not in `AllowedPatterns`' do
      expect_offense(<<~RUBY)
        User.joins(:posts).each { |u| u.something }
                           ^^^^ Use `find_each` instead of `each`.
      RUBY
    end
  end

  context 'ignored methods' do
    let(:cop_config) { { 'AllowedPatterns' => [], 'AllowedMethods' => [], 'IgnoredMethods' => %w[order lock] } }

    it 'does not register an offense when using order(...) earlier' do
      expect_no_offenses('User.order(:name).each { |u| u.something }')
    end

    it 'does not register an offense when using order(...) chained with other things' do
      expect_no_offenses('User.order(:name).includes(:company).each { |u| u.something }')
    end

    it 'does not register an offense when using lock earlier' do
      expect_no_offenses('User.lock.each { |u| u.something }')
    end

    it 'registers offense for methods not in `IgnoredMethods`' do
      expect_offense(<<~RUBY)
        User.joins(:posts).each { |u| u.something }
                           ^^^^ Use `find_each` instead of `each`.
      RUBY
    end
  end
end
