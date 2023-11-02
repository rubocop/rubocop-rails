# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RedundantActiveRecordAllMethod, :config do
  describe "#{described_class}::QUERYING_METHODS" do
    it 'equals defined methods in `ActiveRecord::Querying::QUERYING_METHODS`' do
      expect(described_class::QUERYING_METHODS).to eq(
        %i[
          and
          annotate
          any?
          async_average
          async_count
          async_ids
          async_maximum
          async_minimum
          async_pick
          async_pluck
          async_sum
          average
          calculate
          count
          create_or_find_by
          create_or_find_by!
          create_with
          delete_all
          delete_by
          destroy_all
          destroy_by
          distinct
          eager_load
          except
          excluding
          exists?
          extending
          extract_associated
          fifth
          fifth!
          find
          find_by
          find_by!
          find_each
          find_in_batches
          find_or_create_by
          find_or_create_by!
          find_or_initialize_by
          find_sole_by
          first
          first!
          first_or_create
          first_or_create!
          first_or_initialize
          forty_two
          forty_two!
          fourth
          fourth!
          from
          group
          having
          ids
          in_batches
          in_order_of
          includes
          invert_where
          joins
          last
          last!
          left_joins
          left_outer_joins
          limit
          lock
          many?
          maximum
          merge
          minimum
          none
          none?
          offset
          one?
          only
          optimizer_hints
          or
          order
          pick
          pluck
          preload
          readonly
          references
          regroup
          reorder
          reselect
          rewhere
          second
          second!
          second_to_last
          second_to_last!
          select
          sole
          strict_loading
          sum
          take
          take!
          third
          third!
          third_to_last
          third_to_last!
          touch_all
          unscope
          update_all
          where
          with
          without
        ].to_set
      )
    end
  end

  context 'with receiver' do
    [
      'and(User.where(age: 30))',
      'annotate("selecting id")',
      'any?',
      'average(:age)',
      'calculate(:average, :age)',
      'count',
      'create_or_find_by(name: name)',
      'create_or_find_by!(name: name)',
      'create_with(name: name)',
      'delete_all',
      'delete_by(id: id)',
      'destroy_all',
      'destroy_by(id: id)',
      'distinct',
      'eager_load(:articles)',
      'except(:order)',
      'excluding(user)',
      'exists?',
      'extending(Pagination)',
      'extract_associated(:articles)',
      'fifth',
      'fifth!',
      'find(id)',
      'find_by(name: name)',
      'find_by!(name: name)',
      'find_each(&:do_something)',
      'find_in_batches(&:do_something)',
      'find_or_create_by(name: name)',
      'find_or_create_by!(name: name)',
      'find_or_initialize_by(name: name)',
      'find_sole_by(name: name)',
      'first',
      'first!',
      'first_or_create(name: name)',
      'first_or_create!(name: name)',
      'first_or_initialize(name: name)',
      'forty_two',
      'forty_two!',
      'fourth',
      'fourth!',
      'from("users")',
      'group(:age)',
      'having("AVG(age) > 30")',
      'ids',
      'in_batches(&:do_something)',
      'in_order_of(:id, ids)',
      'includes(:articles)',
      'invert_where',
      'joins(:articles)',
      'last',
      'last!',
      'left_joins(:articles)',
      'left_outer_joins(:articles)',
      'limit(n)',
      'lock',
      'many?',
      'maximum(:age)',
      'merge(users)',
      'minimum(:age)',
      'none',
      'none?',
      'offset(n)',
      'one?',
      'only(:order)',
      'optimizer_hints("SeqScan(users)", "Parallel(users 8)")',
      'or(User.where(age: 30))',
      'order(:created_at)',
      'pick(:id)',
      'pluck(:age)',
      'preload(:articles)',
      'readonly',
      'references(:articles)',
      'reorder(:created_at)',
      'reselect(:age)',
      'rewhere(id: ids)',
      'second',
      'second!',
      'second_to_last',
      'second_to_last!',
      'select(:age)',
      'sole',
      'strict_loading',
      'sum(:age)',
      'take(n)',
      'take!',
      'third',
      'third!',
      'third_to_last',
      'third_to_last!',
      'touch_all',
      'unscope(:order)',
      'update_all(name: name)',
      'where(id: ids)',
      'without(user)'
    ].each do |source|
      it "registers an offense and corrects when `all.#{source}`" do
        expect_offense(<<~RUBY)
          User.all.#{source}
               ^^^ Redundant `all` detected.
        RUBY

        expect_correction(<<~RUBY)
          User.#{source}
        RUBY
      end
    end

    it 'registers an offense and corrects when the receiver for `all` is Active Record relation object' do
      expect_offense(<<~RUBY)
        user.articles.all.order(:created_at)
                      ^^^ Redundant `all` detected.
      RUBY

      expect_correction(<<~RUBY)
        user.articles.order(:created_at)
      RUBY
    end

    it 'does not register an offense when no method follows `all`' do
      expect_no_offenses(<<~RUBY)
        User.all
      RUBY
    end

    it 'does not register an offense when not using defined methods in `ActiveRecord::Querying::QUERYING_METHODS`' do
      expect_no_offenses(<<~RUBY)
        User.all.map(&:do_something)
      RUBY
    end

    context 'when `all` is used as a method parameter' do
      it 'does not register an offense when no method follows `all`' do
        expect_no_offenses(<<~RUBY)
          do_something(User.all)
        RUBY
      end

      it 'registers an offense and corrects when `ActiveRecord::Querying::QUERYING_METHODS` follows `all`' do
        expect_offense(<<~RUBY)
          do_something(User.all.order(:created_at))
                            ^^^ Redundant `all` detected.
        RUBY

        expect_correction(<<~RUBY)
          do_something(User.order(:created_at))
        RUBY
      end

      it 'does not register an offense when method matches `ActiveRecord::Querying::QUERYING_METHODS`' do
        expect_no_offenses(<<~RUBY)
          sum(User.all)
        RUBY
      end
    end

    context 'when `all` has any parameters, it indicates that it is not an Active Record `all`' do
      it 'does not register an offense when no method follows `all`' do
        expect_no_offenses(<<~RUBY)
          page.all(:parameter)
        RUBY
      end

      it 'does not register an offense when method follows `all`' do
        expect_no_offenses(<<~RUBY)
          page.all(:parameter).do_something
        RUBY
      end

      it 'does not register an offense when method from `ActiveRecord::Querying::QUERYING_METHODS` follows `all`' do
        expect_no_offenses(<<~RUBY)
          page.all(:parameter).select(some_filter)
        RUBY
      end
    end

    context 'when `all` has parentheses' do
      it 'does not register an offense when no method follows `all`' do
        expect_no_offenses(<<~RUBY)
          User.all()
        RUBY
      end

      it 'registers an offense and corrects when method in `ActiveRecord::Querying::QUERYING_METHODS` follows `all`' do
        expect_offense(<<~RUBY)
          User.all().order(:created_at)
               ^^^^^ Redundant `all` detected.
        RUBY

        expect_correction(<<~RUBY)
          User.order(:created_at)
        RUBY
      end

      it 'does not register an offense when method not in `ActiveRecord::Querying::QUERYING_METHODS` follows `all`' do
        expect_no_offenses(<<~RUBY)
          User.all().do_something
        RUBY
      end
    end

    described_class::POSSIBLE_ENUMERABLE_BLOCK_METHODS.each do |method|
      context "using `#{method}`" do
        it "does not register an offense when using `#{method}` with block" do
          expect_no_offenses(<<~RUBY)
            User.all.#{method} { |item| item.do_something }
          RUBY
        end

        it "does not register an offense when using `#{method}` with numbered block" do
          expect_no_offenses(<<~RUBY)
            User.all.#{method} { _1.do_something }
          RUBY
        end

        it "does not register an offense when using `#{method}` with symbol block" do
          expect_no_offenses(<<~RUBY)
            User.all.#{method}(&:do_something)
          RUBY
        end
      end
    end
  end

  context 'with no receiver' do
    it 'does not register an offense when not inheriting any class' do
      expect_no_offenses(<<~RUBY)
        class User
          def do_something
            all.where(id: ids)
          end
        end
      RUBY
    end

    it 'does not register an offense when not inheriting `ApplicationRecord`' do
      expect_no_offenses(<<~RUBY)
        class User < Foo
          def do_something
            all.where(id: ids)
          end
        end
      RUBY
    end

    it 'registers an offense when inheriting `ApplicationRecord`' do
      expect_offense(<<~RUBY)
        class User < ApplicationRecord
          scope :admins, -> { all.where(admin: true) }
                              ^^^ Redundant `all` detected.
        end
      RUBY

      expect_correction(<<~RUBY)
        class User < ApplicationRecord
          scope :admins, -> { where(admin: true) }
        end
      RUBY
    end

    it 'registers an offense when inheriting `::ApplicationRecord`' do
      expect_offense(<<~RUBY)
        class User < ::ApplicationRecord
          scope :admins, -> { all.where(admin: true) }
                              ^^^ Redundant `all` detected.
        end
      RUBY

      expect_correction(<<~RUBY)
        class User < ::ApplicationRecord
          scope :admins, -> { where(admin: true) }
        end
      RUBY
    end

    it 'registers an offense when inheriting `ActiveRecord::Base`' do
      expect_offense(<<~RUBY)
        class User < ActiveRecord::Base
          scope :admins, -> { all.where(admin: true) }
                              ^^^ Redundant `all` detected.
        end
      RUBY

      expect_correction(<<~RUBY)
        class User < ActiveRecord::Base
          scope :admins, -> { where(admin: true) }
        end
      RUBY
    end

    it 'registers an offense when inheriting `::ActiveRecord::Base`' do
      expect_offense(<<~RUBY)
        class User < ::ActiveRecord::Base
          scope :admins, -> { all.where(admin: true) }
                              ^^^ Redundant `all` detected.
        end
      RUBY

      expect_correction(<<~RUBY)
        class User < ::ActiveRecord::Base
          scope :admins, -> { where(admin: true) }
        end
      RUBY
    end
  end

  context 'with `AllowedReceivers` config' do
    let(:cop_config) do
      { 'AllowedReceivers' => %w[ActionMailer::Preview ActiveSupport::TimeZone] }
    end

    it 'registers an offense when not using allowed receiver' do
      expect_offense(<<~RUBY)
        User.all.first
             ^^^ Redundant `all` detected.
      RUBY
    end

    it 'does not register an offense when using allowed receiver' do
      expect_no_offenses(<<~RUBY)
        ActiveSupport::TimeZone.all.first
      RUBY
    end
  end
end
