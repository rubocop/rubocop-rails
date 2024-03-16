# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ExpandedDateRange, :config do
  context 'Rails >= 5.1', :rails51 do
    it 'registers and corrects an offense when using `date.beginning_of_day..date.end_of_day`' do
      expect_offense(<<~RUBY)
        date.beginning_of_day..date.end_of_day
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_day` instead.
      RUBY

      expect_correction(<<~RUBY)
        date.all_day
      RUBY
    end

    it 'registers and corrects an offense when using `date.beginning_of_week..date.end_of_week`' do
      expect_offense(<<~RUBY)
        date.beginning_of_week..date.end_of_week
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_week` instead.
      RUBY

      expect_correction(<<~RUBY)
        date.all_week
      RUBY
    end

    it 'registers and corrects an offense when using `date.beginning_of_month..date.end_of_month`' do
      expect_offense(<<~RUBY)
        date.beginning_of_month..date.end_of_month
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_month` instead.
      RUBY

      expect_correction(<<~RUBY)
        date.all_month
      RUBY
    end

    it 'registers and corrects an offense when using `date.beginning_of_quarter..date.end_of_quarter`' do
      expect_offense(<<~RUBY)
        date.beginning_of_quarter..date.end_of_quarter
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_quarter` instead.
      RUBY

      expect_correction(<<~RUBY)
        date.all_quarter
      RUBY
    end

    it 'registers and corrects an offense when using `date.beginning_of_week(:sunday)..date.end_of_week(:sunday)`' do
      expect_offense(<<~RUBY)
        date.beginning_of_week(:sunday)..date.end_of_week(:sunday)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_week(:sunday)` instead.
      RUBY

      expect_correction(<<~RUBY)
        date.all_week(:sunday)
      RUBY
    end

    it 'does not register an offense when using `date.beginning_of_week(:sunday)..date.end_of_week`' do
      expect_no_offenses(<<~RUBY)
        date.beginning_of_week(:sunday)..date.end_of_week
      RUBY
    end

    it 'registers and corrects an offense when using `date.beginning_of_year..date.end_of_year`' do
      expect_offense(<<~RUBY)
        date.beginning_of_year..date.end_of_year
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_year` instead.
      RUBY

      expect_correction(<<~RUBY)
        date.all_year
      RUBY
    end

    it 'registers and corrects an offense when using an expanded date range as a method argument' do
      expect_offense(<<~RUBY)
        Model.do_something(foo_at: date.beginning_of_day..date.end_of_day)
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_day` instead.
      RUBY

      expect_correction(<<~RUBY)
        Model.do_something(foo_at: date.all_day)
      RUBY
    end

    it 'registers and corrects an offense when assigning expanded date range' do
      expect_offense(<<~RUBY)
        foo_at = date.beginning_of_day..date.end_of_day
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_day` instead.
        Model.find_by(foo_at: foo_at)
      RUBY

      expect_correction(<<~RUBY)
        foo_at = date.all_day
        Model.find_by(foo_at: foo_at)
      RUBY
    end

    it 'registers and corrects an offense when using multiple expanded date range conditions' do
      expect_offense(<<~RUBY)
        Model.where(foo_at: date1.beginning_of_week..date1.end_of_week, bar_at: date2.beginning_of_year..date2.end_of_year)
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date1.all_week` instead.
                                                                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date2.all_year` instead.
      RUBY

      expect_correction(<<~RUBY)
        Model.where(foo_at: date1.all_week, bar_at: date2.all_year)
      RUBY
    end

    it 'does not register an offense when using `...` range syntax' do
      expect_no_offenses(<<~RUBY)
        date.beginning_of_day...date.end_of_day
      RUBY
    end

    it 'does not register an offense when variables are different at the beginning and end of the range' do
      expect_no_offenses(<<~RUBY)
        date1.beginning_of_day..date2.end_of_day
      RUBY
    end

    it 'does not register an offense when unmapped methods are at the beginning and end of the range' do
      expect_no_offenses(<<~RUBY)
        date.beginning_of_day..date.end_of_year
      RUBY
    end

    it 'does not register an offense when `date.beginning_of_week(:sunday)..date.end_of_week(:saturday)`' do
      expect_no_offenses(<<~RUBY)
        date.beginning_of_week(:sunday)..date.end_of_week(:saturday)
      RUBY
    end

    it 'does not register an offense when `date.beginning_of_day..date.end_of_day` with any argument' do
      expect_no_offenses(<<~RUBY)
        date.beginning_of_day(arg)..date.end_of_day(arg)
      RUBY
    end

    it 'does not register an offense when `beginning_of_day..end_of_day`' do
      expect_no_offenses(<<~RUBY)
        beginning_of_day..end_of_day
      RUBY
    end

    it 'does not register an offense when `beginning_of_day..date.end_of_day`' do
      expect_no_offenses(<<~RUBY)
        beginning_of_day..date.end_of_day
      RUBY
    end

    it 'does not register an offense when `date.beginning_of_day..end_of_day`' do
      expect_no_offenses(<<~RUBY)
        date.beginning_of_day..end_of_day
      RUBY
    end
  end

  context 'Rails <= 5.0', :rails50 do
    it 'does not register an offense when using `date.beginning_of_day..date.end_of_day`' do
      expect_no_offenses(<<~RUBY)
        date.beginning_of_day..date.end_of_day
      RUBY
    end

    it 'does not register an offense when using `date.beginning_of_week..date.end_of_week`' do
      expect_no_offenses(<<~RUBY)
        date.beginning_of_week..date.end_of_week
      RUBY
    end

    it 'does not register an offense when using `date.beginning_of_month..date.end_of_month`' do
      expect_no_offenses(<<~RUBY)
        date.beginning_of_month..date.end_of_month
      RUBY
    end

    it 'does not register an offense when using `date.beginning_of_quarter..date.end_of_quarter`' do
      expect_no_offenses(<<~RUBY)
        date.beginning_of_quarter..date.end_of_quarter
      RUBY
    end

    it 'does not register an offense when using `date.beginning_of_year..date.end_of_year`' do
      expect_no_offenses(<<~RUBY)
        date.beginning_of_year..date.end_of_year
      RUBY
    end
  end
end
