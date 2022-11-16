# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ToSWithArgument, :config, :rails70 do
  context 'without argument' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        to_s
      RUBY
    end
  end

  context 'with unrelated argument' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        10.to_s(2)
      RUBY
    end
  end

  context 'with argument' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        to_s(:delimited)
        ^^^^ Use `to_formatted_s` instead.
      RUBY

      expect_correction(<<~RUBY)
        to_formatted_s(:delimited)
      RUBY
    end
  end

  context 'with argument and receiver' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        1.to_s(:delimited)
          ^^^^ Use `to_formatted_s` instead.
      RUBY

      expect_correction(<<~RUBY)
        1.to_formatted_s(:delimited)
      RUBY
    end
  end

  context 'with argument and safe navigation operator' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        1&.to_s(:delimited)
           ^^^^ Use `to_formatted_s` instead.
      RUBY

      expect_correction(<<~RUBY)
        1&.to_formatted_s(:delimited)
      RUBY
    end
  end

  context 'with argument on Rails 6.1', :rails61 do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        to_s(:delimited)
      RUBY
    end
  end
end
