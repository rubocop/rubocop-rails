# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ToFormattedS, :config do
  context 'Rails >= 7.0', :rails70 do
    context 'EnforcedStyle: to_fs' do
      let(:cop_config) { { 'EnforcedStyle' => 'to_fs' } }

      it 'registers and corrects an offense when using `to_formatted_s`' do
        expect_offense(<<~RUBY)
          time.to_formatted_s(:db)
               ^^^^^^^^^^^^^^ Use `to_fs` instead.
        RUBY

        expect_correction(<<~RUBY)
          time.to_fs(:db)
        RUBY
      end

      it 'registers and corrects an offense when using `to_formatted_s` with safe navigation operator' do
        expect_offense(<<~RUBY)
          time&.to_formatted_s(:db)
                ^^^^^^^^^^^^^^ Use `to_fs` instead.
        RUBY

        expect_correction(<<~RUBY)
          time&.to_fs(:db)
        RUBY
      end

      it 'does not register an offense when using `to_fs`' do
        expect_no_offenses(<<~RUBY)
          time.to_fs(:db)
        RUBY
      end
    end

    context 'EnforcedStyle: to_formatted_s' do
      let(:cop_config) { { 'EnforcedStyle' => 'to_formatted_s' } }

      it 'registers and corrects an offense when using `to_fs`' do
        expect_offense(<<~RUBY)
          time.to_fs(:db)
               ^^^^^ Use `to_formatted_s` instead.
        RUBY

        expect_correction(<<~RUBY)
          time.to_formatted_s(:db)
        RUBY
      end

      it 'registers and corrects an offense when using `to_fs` with safe navigation operator' do
        expect_offense(<<~RUBY)
          time&.to_fs(:db)
                ^^^^^ Use `to_formatted_s` instead.
        RUBY

        expect_correction(<<~RUBY)
          time&.to_formatted_s(:db)
        RUBY
      end

      it 'does not register an offense when using `to_formatted_s`' do
        expect_no_offenses(<<~RUBY)
          time.to_formatted_s(:db)
        RUBY
      end
    end
  end

  context 'Rails <= 6.1', :rails61 do
    context 'EnforcedStyle: to_fs' do
      let(:cop_config) { { 'EnforcedStyle' => 'to_fs' } }

      it 'does not register an offense when using `to_formatted_s`' do
        expect_no_offenses(<<~RUBY)
          time.to_formatted_s(:db)
        RUBY
      end
    end

    context 'EnforcedStyle: to_formatted_s' do
      let(:cop_config) { { 'EnforcedStyle' => 'to_formatted_s' } }

      it 'does not register an offense when using `to_fs`' do
        expect_no_offenses(<<~RUBY)
          time.to_fs(:db)
        RUBY
      end
    end
  end
end
