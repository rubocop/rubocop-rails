# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TimeZone, :config do
  context 'when EnforcedStyle is "strict"' do
    let(:cop_config) { { 'EnforcedStyle' => 'strict' } }

    it 'registers an offense for Time.now' do
      expect_offense(<<~RUBY)
        Time.now
             ^^^ Do not use `Time.now` without zone. Use `Time.zone.now` instead.
      RUBY
    end

    it 'registers an offense for Time.now with nil :in option' do
      expect_offense(<<~RUBY)
        Time.now(in: nil)
             ^^^ Do not use `Time.now` without zone. Use `Time.zone.now` instead.
      RUBY
    end

    it 'does not register an offense for Time.now with :in option' do
      expect_no_offenses(<<~RUBY)
        Time.now(in: '+03:00')
      RUBY
    end

    it 'registers an offense for Time.new without argument' do
      expect_offense(<<~RUBY)
        Time.new
             ^^^ Do not use `Time.new` without zone. Use `Time.zone.now` instead.
      RUBY

      expect_correction(<<~RUBY)
        Time.zone.now
      RUBY
    end

    it 'registers an offense for Time.new with argument' do
      expect_offense(<<~RUBY)
        Time.new(2012, 6, 10, 12, 00)
             ^^^ Do not use `Time.new` without zone. Use `Time.zone.local` instead.
      RUBY

      expect_correction(<<~RUBY)
        Time.zone.local(2012, 6, 10, 12, 00)
      RUBY
    end

    it 'does not register an offense when a .new method is called independently of the Time class' do
      expect_no_offenses(<<~RUBY)
        Range.new(1, Time.class.to_s)
      RUBY
    end

    it 'does not register an offense for Time.new with zone argument' do
      expect_no_offenses(<<~RUBY)
        Time.new(1988, 3, 15, 3, 0, 0, '-05:00')
      RUBY
    end

    it 'registers an offense for Time.new with nil :in option' do
      expect_offense(<<~RUBY)
        Time.new(2012, 6, 10, 12, 00, in: nil)
             ^^^ Do not use `Time.new` without zone. Use `Time.zone.local` instead.
      RUBY
    end

    it 'does not register an offense for Time.new with :in option' do
      expect_no_offenses(<<~RUBY)
        Time.new(2012, 6, 10, 12, 00, in: '-05:00')
      RUBY
    end

    it 'registers an offense for ::Time.now' do
      expect_offense(<<~RUBY)
        ::Time.now
               ^^^ Do not use `Time.now` without zone. Use `Time.zone.now` instead.
      RUBY
    end

    it 'accepts Some::Time.now' do
      expect_no_offenses(<<~RUBY)
        Some::Time.now(0).strftime('%H:%M')
      RUBY
    end

    described_class::ACCEPTED_METHODS.each do |a_method|
      it "registers an offense Time.now.#{a_method}" do
        expect_offense(<<~RUBY, a_method: a_method)
          Time.now.#{a_method}
               ^^^ Do not use `Time.now` without zone. Use `Time.zone.now` instead.
        RUBY
      end
    end

    context 'autocorrect' do
      let(:cop_config) do
        { 'AutoCorrect' => 'true', 'EnforcedStyle' => 'strict' }
      end

      it 'autocorrects correctly' do
        expect_offense(<<~RUBY)
          Time.now.in_time_zone
               ^^^ Do not use `Time.now` without zone. Use `Time.zone.now` instead.
        RUBY

        expect_correction(<<~RUBY)
          Time.zone.now
        RUBY
      end

      # :current is a special case and is treated separately below
      (described_class::DANGEROUS_METHODS - %i[current new]).each do |a_method|
        it 'corrects the error' do
          expect_offense(<<~RUBY, a_method: a_method)
            Time.#{a_method}
                 ^{a_method} Do not use `Time.#{a_method}` without zone. Use `Time.zone.#{a_method}` instead.
          RUBY

          expect_correction(<<~RUBY)
            Time.zone.#{a_method}
          RUBY
        end
      end
    end

    it 'registers an offense for `String#to_time`' do
      expect_offense(<<~RUBY)
        "2012-03-02 16:05:37".to_time
                              ^^^^^^^ Do not use `String#to_time` without zone. Use `Time.zone.parse` instead.
      RUBY

      expect_correction(<<~RUBY)
        Time.zone.parse("2012-03-02 16:05:37")
      RUBY
    end

    it 'registers an offense for `to_time` with safe navigation' do
      expect_offense(<<~RUBY)
        "2012-03-02 16:05:37"&.to_time
                               ^^^^^^^ Do not use `String#to_time` without zone. Use `Time.zone.parse` instead.
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for `to_time` without receiver' do
      expect_no_offenses(<<~RUBY)
        to_time
      RUBY
    end

    it 'registers an offense for Time.parse' do
      expect_offense(<<~RUBY)
        Time.parse("2012-03-02 16:05:37")
             ^^^^^ Do not use `Time.parse` without zone. Use `Time.zone.parse` instead.
      RUBY
    end

    it 'does not register an offense when attaching timezone specifier `Z`' do
      expect_no_offenses(<<~RUBY)
        Time.parse("2012-03-02T16:05:37Z")
      RUBY
    end

    it 'does not register an offense when attaching timezone specifier `z`' do
      expect_no_offenses(<<~RUBY)
        Time.parse("2012-03-02T16:05:37z")
      RUBY
    end

    it 'does not register an offense when attaching timezone specifier `E`' do
      expect_no_offenses(<<~RUBY)
        Time.parse("2012-03-02T16:05:37E")
      RUBY
    end

    it 'does not register an offense when attaching timezone offset' do
      expect_no_offenses(<<~RUBY)
        Time.parse("2012-03-02 16:05:37 +0100")
      RUBY
    end

    it 'does not register an offense when attaching timezone offset using a colon' do
      expect_no_offenses(<<~RUBY)
        Time.parse("2012-03-02 16:05:37 +01:00")
      RUBY
    end

    it 'registers an offense for Time.at' do
      expect_offense(<<~RUBY)
        Time.at(ts)
             ^^ Do not use `Time.at` without zone. Use `Time.zone.at` instead.
      RUBY
    end

    it 'registers an offense for Time.at.in_time_zone' do
      expect_offense(<<~RUBY)
        Time.at(ts).in_time_zone
             ^^ Do not use `Time.at` without zone. Use `Time.zone.at` instead.
      RUBY
    end

    it 'registers an offense for Time.at with nil :in option' do
      expect_offense(<<~RUBY)
        Time.at(ts, in: nil)
             ^^ Do not use `Time.at` without zone. Use `Time.zone.at` instead.
      RUBY
    end

    it 'does not register an offense for Time.at with :in option' do
      expect_no_offenses(<<~RUBY)
        Time.at(ts, in: '+03:00')
      RUBY
    end

    it 'registers an offense for Time.parse.localtime(offset)' do
      expect_offense(<<~RUBY)
        Time.parse('12:00').localtime('+03:00')
             ^^^^^ Do not use `Time.parse` without zone. Use `Time.zone.parse` instead.
      RUBY
    end

    it 'registers an offense for Time.parse.localtime' do
      expect_offense(<<~RUBY)
        Time.parse('12:00').localtime
             ^^^^^ Do not use `Time.parse` without zone. Use `Time.zone.parse` instead.
      RUBY
    end

    it 'registers an offense for Time.parse in return' do
      expect_offense(<<~RUBY)
        return Foo, Time.parse("2012-03-02 16:05:37")
                         ^^^^^ Do not use `Time.parse` without zone. Use `Time.zone.parse` instead.
      RUBY
    end

    it 'accepts Time.current' do
      expect_no_offenses(<<~RUBY)
        Time.current
      RUBY
    end

    it 'accepts Time.zone.now' do
      expect_no_offenses('Time.zone.now')
    end

    it 'accepts Time.zone.today' do
      expect_no_offenses('Time.zone.today')
    end

    it 'accepts Time.zone.local' do
      expect_no_offenses('Time.zone.local(2012, 6, 10, 12, 00)')
    end

    it 'accepts Time.zone.parse' do
      expect_no_offenses('Time.zone.parse("2012-03-02 16:05:37")')
    end

    it 'accepts Time.zone.at' do
      expect_no_offenses('Time.zone.at(ts)')
    end

    it 'accepts Time.zone.parse.localtime' do
      expect_no_offenses("Time.zone.parse('12:00').localtime")
    end

    it 'accepts Time.zone.parse.localtime(offset)' do
      expect_no_offenses("Time.zone.parse('12:00').localtime('+03:00')")
    end

    it 'accepts Time.zone_default.now' do
      expect_no_offenses('Time.zone_default.now')
    end

    it 'accepts Time.zone_default.today' do
      expect_no_offenses('Time.zone_default.today')
    end

    it 'accepts Time.zone_default.local' do
      expect_no_offenses('Time.zone_default.local(2012, 6, 10, 12, 00)')
    end

    it 'accepts Time.find_zone(time_zone).now' do
      expect_no_offenses("Time.find_zone('EST').now")
    end

    it 'accepts Time.find_zone(time_zone).today' do
      expect_no_offenses("Time.find_zone('EST').today")
    end

    it 'accepts Time.find_zone(time_zone).local' do
      expect_no_offenses("Time.find_zone('EST').local(2012, 6, 10, 12, 00)")
    end

    it 'accepts Time.find_zone!(time_zone).now' do
      expect_no_offenses("Time.find_zone!('EST').now")
    end

    it 'accepts Time.find_zone!(time_zone).today' do
      expect_no_offenses("Time.find_zone!('EST').today")
    end

    it 'accepts Time.find_zone!(time_zone).local' do
      expect_no_offenses("Time.find_zone!('EST').local(2012, 6, 10, 12, 00)")
    end

    described_class::DANGEROUS_METHODS.each do |a_method|
      it "accepts Some::Time.#{a_method}" do
        expect_no_offenses(<<~RUBY)
          Some::Time.#{a_method}
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is "flexible"' do
    let(:cop_config) { { 'EnforcedStyle' => 'flexible' } }

    it 'registers an offense for Time.now' do
      expect_offense(<<~RUBY)
        Time.now
             ^^^ Do not use `Time.now` without zone. Use one of `Time.zone.now`, `Time.current`, `Time.now.in_time_zone`, `Time.now.utc`, `Time.now.getlocal`, `Time.now.xmlschema`, `Time.now.iso8601`, `Time.now.jisx0301`, `Time.now.rfc3339`, `Time.now.httpdate`, `Time.now.to_i`, `Time.now.to_f` instead.
      RUBY
    end

    it 'accepts Time.current' do
      expect_no_offenses(<<~RUBY)
        Time.current
      RUBY
    end

    described_class::ACCEPTED_METHODS.each do |a_method|
      it "accepts Time.now.#{a_method}" do
        expect_no_offenses(<<~RUBY)
          Time.now.#{a_method}
        RUBY
      end
    end

    it 'accepts Time.zone.now' do
      expect_no_offenses(<<~RUBY)
        Time.zone.now
      RUBY
    end

    it 'accepts Time.zone_default.now' do
      expect_no_offenses(<<~RUBY)
        Time.zone_default.now
      RUBY
    end

    it 'accepts Time.find_zone(time_zone).now' do
      expect_no_offenses(<<~RUBY)
        Time.find_zone('EST').now
      RUBY
    end

    it 'accepts Time.find_zone!(time_zone).now' do
      expect_no_offenses(<<~RUBY)
        Time.find_zone!('EST').now
      RUBY
    end

    described_class::DANGEROUS_METHODS.each do |a_method|
      it "accepts Time.current.#{a_method}" do
        expect_no_offenses(<<~RUBY)
          Time.current.#{a_method}
        RUBY
      end

      context 'autocorrect' do
        let(:cop_config) do
          { 'AutoCorrect' => 'true', 'EnforcedStyle' => 'flexible' }
        end
        let(:no_autocorrect_required_methods) do
          %i[current new]
        end

        it 'corrects the error' do
          source = <<~RUBY
            Time.#{a_method}
          RUBY
          new_source = autocorrect_source(source)
          unless no_autocorrect_required_methods.include?(a_method)
            expect(new_source).to eq(<<~RUBY)
              Time.zone.#{a_method}
            RUBY
          end
        end
      end
    end

    it 'accepts Time.parse.localtime(offset)' do
      expect_no_offenses("Time.parse('12:00').localtime('+03:00')")
    end

    it 'does not blow up in the presence of a single constant to inspect' do
      expect_no_offenses('A')
    end
  end
end
