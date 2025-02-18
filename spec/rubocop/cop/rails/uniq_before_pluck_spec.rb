# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::UniqBeforePluck, :config do
  shared_examples_for 'mode-independent behavior' do
    it 'corrects' do
      expect_offense(<<~RUBY)
        Model.pluck(:name).uniq
                           ^^^^ Use `distinct` before `pluck`.
      RUBY

      expect_correction(<<~RUBY)
        Model.distinct.pluck(:name)
      RUBY
    end

    it 'corrects hanging period' do
      expect_offense(<<~RUBY)
        Model.pluck(:name)
          .uniq
           ^^^^ Use `distinct` before `pluck`.
      RUBY

      expect_correction(<<~RUBY)
        Model.distinct.pluck(:name)
      RUBY
    end

    it 'corrects trailing period' do
      expect_offense(<<~RUBY)
        Model.pluck(:name).
          uniq
          ^^^^ Use `distinct` before `pluck`.
      RUBY

      expect_correction(<<~RUBY)
        Model.distinct.pluck(:name)
      RUBY
    end

    it 'corrects when uniq and pluck are on different lines' do
      expect_offense(<<~RUBY)
        Model
          .pluck(:name)
          .uniq
           ^^^^ Use `distinct` before `pluck`.
      RUBY

      expect_correction(<<~RUBY)
        Model
          .distinct.pluck(:name)
      RUBY
    end

    it 'ignores uniq before pluck' do
      expect_no_offenses(<<~RUBY)
        Model.where(foo: 1).uniq.pluck(:something)
      RUBY
    end

    it 'ignores uniq without a receiver' do
      expect_no_offenses(<<~RUBY)
        uniq.something
      RUBY
    end

    it 'ignores uniq without pluck' do
      expect_no_offenses(<<~RUBY)
        Model.uniq
      RUBY
    end

    it 'ignores uniq with a block' do
      expect_no_offenses(<<~RUBY)
        Model.where(foo: 1).pluck(:name).uniq { |k| k[0] }
      RUBY
    end
  end

  it 'registers an offense' do
    expect_offense(<<~RUBY)
      Model.pluck(:name).uniq
                         ^^^^ Use `distinct` before `pluck`.
    RUBY
  end

  context 'when the enforced mode is conservative' do
    let(:cop_config) { { 'EnforcedStyle' => 'conservative' } }

    it_behaves_like 'mode-independent behavior'

    it 'ignores model with a scope' do
      expect_no_offenses(<<~RUBY)
        Model.scope.pluck(:name).uniq
      RUBY
    end

    it 'ignores uniq on an association' do
      expect_no_offenses(<<~RUBY)
        instance.assoc.pluck(:name).uniq
      RUBY
    end

    it 'ignores uniq without an receiver' do
      expect_no_offenses(<<~RUBY)
        pluck(:name).uniq
      RUBY
    end
  end

  context 'when the enforced mode is aggressive' do
    let(:cop_config) { { 'EnforcedStyle' => 'aggressive' } }

    it_behaves_like 'mode-independent behavior'

    it 'corrects model with a scope' do
      expect_offense(<<~RUBY)
        Model.scope.pluck(:name).uniq
                                 ^^^^ Use `distinct` before `pluck`.
      RUBY

      expect_correction(<<~RUBY)
        Model.scope.distinct.pluck(:name)
      RUBY
    end

    it 'corrects uniq on an association' do
      expect_offense(<<~RUBY)
        instance.assoc.pluck(:name).uniq
                                    ^^^^ Use `distinct` before `pluck`.
      RUBY

      expect_correction(<<~RUBY)
        instance.assoc.distinct.pluck(:name)
      RUBY
    end

    it 'corrects uniq when used without a receiver' do
      expect_offense(<<~RUBY)
        pluck(:name).uniq
                     ^^^^ Use `distinct` before `pluck`.
      RUBY

      expect_correction(<<~RUBY)
        distinct.pluck(:name)
      RUBY
    end
  end
end
