# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Date, :config do
  context 'when EnforcedStyle is "strict"' do
    let(:cop_config) { { 'EnforcedStyle' => 'strict', 'AllowToTime' => allow_to_time } }
    let(:allow_to_time) { true }

    shared_examples 'offense' do |method, message|
      it "registers an offense for #{method}" do
        offenses = inspect_source(method)
        expect(offenses.first.message).to eq(message)
      end
    end

    %w[today yesterday tomorrow].each do |day|
      it_behaves_like(
        'offense',
        "Date.#{day}",
        "Do not use `Date.#{day}` without zone. Use `Time.zone.#{day}` instead."
      )

      it_behaves_like(
        'offense',
        "::Date.#{day}",
        "Do not use `Date.#{day}` without zone. Use `Time.zone.#{day}` instead."
      )

      it "accepts Some::Date.#{day}" do
        expect_no_offenses("Some::Date.#{day}")
      end
    end

    context 'when using Date.current' do
      it_behaves_like(
        'offense',
        'Date.current',
        'Do not use `Date.current` without zone. Use `Time.zone.today` instead.'
      )

      it_behaves_like(
        'offense',
        '::Date.current',
        'Do not use `Date.current` without zone. Use `Time.zone.today` instead.'
      )

      it 'accepts Some::Date.current' do
        expect_no_offenses('Some::Date.current')
      end
    end

    context 'when using `to_time_in_current_zone`' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          date.to_time_in_current_zone
               ^^^^^^^^^^^^^^^^^^^^^^^ `to_time_in_current_zone` is deprecated. Use `in_time_zone` instead.
        RUBY

        expect_correction(<<~RUBY)
          date.in_time_zone
        RUBY
      end

      context 'when using safe navigation operator' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            date&.to_time_in_current_zone
                  ^^^^^^^^^^^^^^^^^^^^^^^ `to_time_in_current_zone` is deprecated. Use `in_time_zone` instead.
          RUBY

          expect_correction(<<~RUBY)
            date&.in_time_zone
          RUBY
        end
      end

      it 'accepts variable named `to_time_in_current_zone`' do
        expect_no_offenses('to_time_in_current_zone = 1')
      end

      it 'accepts variable `to_time_in_current_zone` as range end' do
        expect_no_offenses('date..to_time_in_current_zone')
      end
    end

    context 'when a zone is provided' do
      it 'does not register an offense' do
        expect_no_offenses('date.to_time(:utc)')
      end
    end

    context 'when a string literal with timezone' do
      it 'does not register an offense' do
        expect_no_offenses('"2016-07-12 14:36:31 +0100".to_time(:utc)')
      end
    end

    context 'when using `to_time`' do
      context 'when `AllowToTime: true`' do
        let(:allow_to_time) { true }

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            date.to_time
          RUBY
        end

        context 'when using safe navigation operator' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              date&.to_time
            RUBY
          end
        end

        it 'accepts variable named `to_time`' do
          expect_no_offenses('to_time = 1')
        end

        it 'accepts variable `to_time` as range end' do
          expect_no_offenses('date..to_time')
        end

        context 'when a string literal without timezone' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              "2016-07-12 14:36:31".to_time(:utc)
            RUBY
          end
        end

        RuboCop::Cop::Rails::TimeZone::ACCEPTED_METHODS.each do |a_method|
          it "does not register an offense for val.to_time.#{a_method}" do
            expect_no_offenses(<<~RUBY)
              val.to_time.#{a_method}
            RUBY
          end
        end
      end

      context 'when `AllowToTime: false`' do
        let(:allow_to_time) { false }

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            date.to_time
                 ^^^^^^^ Do not use `to_time` on Date objects, because they know nothing about the time zone in use.
          RUBY

          expect_no_corrections
        end

        context 'when using safe navigation operator' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              date&.to_time
                    ^^^^^^^ Do not use `to_time` on Date objects, because they know nothing about the time zone in use.
            RUBY

            expect_no_corrections
          end
        end

        it 'accepts variable named `to_time`' do
          expect_no_offenses('to_time = 1')
        end

        it 'accepts variable `to_time` as range end' do
          expect_no_offenses('date..to_time')
        end

        context 'when a string literal without timezone' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              "2016-07-12 14:36:31".to_time(:utc)
                                    ^^^^^^^ Do not use `to_time` on Date objects, because they know nothing about the time zone in use.
            RUBY

            expect_no_corrections
          end
        end

        RuboCop::Cop::Rails::TimeZone::ACCEPTED_METHODS.each do |a_method|
          it "registers an offense for val.to_time.#{a_method}" do
            offenses = inspect_source("val.to_time.#{a_method}")
            expect(offenses.size).to eq(1)
          end
        end
      end
    end

    context 'when a string literal with "Z"-style UTC timezone' do
      it 'does not register an offense' do
        expect_no_offenses('"2017-09-22T22:46:06.497Z".to_time(:utc)')
      end
    end

    it 'does not blow up in the presence of a single constant to inspect' do
      expect_no_offenses('A')
    end

    it 'registers an offense for #to_time_in_current_zone' do
      expect_offense(<<~RUBY)
        "2016-07-12 14:36:31".to_time_in_current_zone
                              ^^^^^^^^^^^^^^^^^^^^^^^ `to_time_in_current_zone` is deprecated. Use `in_time_zone` instead.
      RUBY

      expect_correction(<<~RUBY)
        "2016-07-12 14:36:31".in_time_zone
      RUBY
    end
  end

  context 'when EnforcedStyle is "flexible"' do
    let(:cop_config) { { 'EnforcedStyle' => 'flexible' } }

    %w[current yesterday tomorrow].each do |day|
      it "accepts Date.#{day}" do
        expect_no_offenses("Date.#{day}")
      end
    end

    it 'registers an offense for Date.today' do
      expect_offense(<<~RUBY)
        Date.today
             ^^^^^ Do not use `Date.today` without zone. Use `Time.zone.today` instead.
      RUBY

      expect_correction(<<~RUBY)
        Time.zone.today
      RUBY
    end

    it 'registers an offense for ::Date.today' do
      expect_offense(<<~RUBY)
        ::Date.today
               ^^^^^ Do not use `Date.today` without zone. Use `Time.zone.today` instead.
      RUBY

      expect_correction(<<~RUBY)
        ::Time.zone.today
      RUBY
    end

    RuboCop::Cop::Rails::TimeZone::ACCEPTED_METHODS.each do |a_method|
      it "accepts val.to_time.#{a_method}" do
        expect_no_offenses("val.to_time.#{a_method}")
      end
    end

    it 'registers an offense for #to_time_in_current_zone' do
      expect_offense(<<~RUBY)
        "2016-07-12 14:36:31".to_time_in_current_zone
                              ^^^^^^^^^^^^^^^^^^^^^^^ `to_time_in_current_zone` is deprecated. Use `in_time_zone` instead.
      RUBY

      expect_correction(<<~RUBY)
        "2016-07-12 14:36:31".in_time_zone
      RUBY
    end
  end
end
