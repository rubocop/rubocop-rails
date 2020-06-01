# frozen_string_literal: true

# FIXME: Do not merge until this can be, and is, removed
module ExpectNoCorrectionsPolyfill
  private

  # yoiked from https://github.com/rubocop-hq/rubocop/pull/6752, following
  # https://github.com/rubocop-hq/rubocop-rails/pull/38#issuecomment-464438473
  def expect_no_corrections
    unless @processed_source
      raise '`expect_no_correctionss` must follow `expect_offense`'
    end

    return if cop.corrections.empty?

    # In order to print a nice diff, e.g. what source got corrected to,
    # we need to run the actual corrections

    corrector =
      RuboCop::Cop::Corrector.new(@processed_source.buffer, cop.corrections)
    new_source = corrector.rewrite

    expect(new_source).to eq(@processed_source.buffer.source)
  end
end

RSpec.configure do |config|
  # binding.pry

  config.include ExpectNoCorrectionsPolyfill
end

# FIXME: Need more specific tests per Rails version
# - **4.1** introduces `travel`, `travel_to`, & `travel_back`
# - **5.2** introduces `freeze_time` alias for `travel_to(Time.now)`
# - **6.0** _will introduce_ `unfreeze_time` alias for `travel_back`

# Ideally, we would provide the following experience:

# - **Version < 4.1**: No offences or corrections
# - **4.1 >= Versions < 5.2**: Use only `travel` & `travel_to`
# - **5.2 >= Versions < 6.0**: Change to include `freeze_time`
# - **6.0 >= Versions**: Change to include `unfreeze_time`

# With major version restrictions, that means we can only provide the following:

# - **Versions < 5.0**: No offences or corrections
# - **5.0 >= Versions < 6.0**: Use only `travel` & `travel_to`
# - **6.0 >= Versions**: Change to include `freeze_time` & `unfreeze_time`

RSpec.describe RuboCop::Cop::Rails::Timecop do
  subject(:cop) { described_class.new }

  describe 'Timecop.freeze' do
    context 'without a block' do
      context 'without arguments' do
        it 'adds an offense, and corrects to `freeze_time`' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.freeze
            ^^^^^^^^^^^^^^ Use `freeze_time` instead of `Timecop.freeze`
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            freeze_time
          RUBY
        end
      end

      context 'with arguments' do
        it 'adds an offense, and does not correct' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.freeze(123)
            ^^^^^^^^^^^^^^^^^^^ Use `travel` or `travel_to` instead of `Timecop.freeze`
          RUBY

          expect_no_corrections
        end
      end
    end

    context 'with a block' do
      context 'without arguments' do
        it 'adds an offense, and autocorrects to `freeze_time`' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.freeze { assert true }
            ^^^^^^^^^^^^^^ Use `freeze_time` instead of `Timecop.freeze`
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            freeze_time { assert true }
          RUBY
        end
      end

      context 'with arguments' do
        it 'adds an offense, and does not autocorrect' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.freeze(123) { assert true }
            ^^^^^^^^^^^^^^^^^^^ Use `travel` or `travel_to` instead of `Timecop.freeze`
          RUBY

          expect_no_corrections
        end
      end
    end
  end

  describe 'Timecop.return' do
    context 'without a block' do
      context 'in Rails < 6.0', :rails5 do
        it 'adds an offense, and corrects to `travel_back`' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.return
            ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            travel_back
          RUBY
        end

        context 'inside a block' do
          it 'adds an offense, and corrects to `travel_back`' do
            expect_offense(<<-RUBY.strip_indent)
              foo { Timecop.return }
                    ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
            RUBY

            expect_correction(<<-RUBY.strip_indent)
              foo { travel_back }
            RUBY
          end
        end
      end

      context 'in Rails >= 6.0', :rails6 do
        it 'adds an offense, and corrects to `travel_back`' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.return
            ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            travel_back
          RUBY
        end

        context 'inside a block' do
          it 'adds an offense, and corrects to `travel_back`' do
            expect_offense(<<-RUBY.strip_indent)
              foo { Timecop.return }
                    ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
            RUBY

            expect_correction(<<-RUBY.strip_indent)
              foo { travel_back }
            RUBY
          end
        end
      end

      # context 'in Rails > 6.0', :rails6 do
      #   it 'autocorrects to `unfreeze_time`' do
      #     expect(autocorrect_source('Timecop.return')).to(eq('unfreeze_time'))
      #   end

      #   context 'inside a block' do
      #     it 'autocorrects to `unfreeze_time`' do
      #       expect(autocorrect_source('foo { Timecop.return }'))
      #         .to(eq('foo { unfreeze_time }'))
      #     end
      #   end
      # end
    end

    context 'with a block' do
      it 'adds an offense, and does not correct' do
        expect_offense(<<-RUBY.strip_indent)
          Timecop.return { assert true }
          ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
        RUBY

        expect_no_corrections
      end

      context 'inside a block' do
        it 'adds an offense, and does not correct' do
          expect_offense(<<-RUBY.strip_indent)
            foo { Timecop.return { assert true } }
                  ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
          RUBY

          expect_no_corrections
        end
      end
    end
  end

  describe 'Timecop.travel' do
    it 'adds an offense, and does not correct' do
      expect_offense(<<-RUBY.strip_indent)
        Timecop.travel(123) { assert true }
        ^^^^^^^^^^^^^^^^^^^ Use `travel` or `travel_to` instead of `Timecop.travel`. If you need time to keep flowing, simulate it by travelling again.
      RUBY

      expect_no_corrections
    end
  end

  describe 'Timecop.*' do
    it 'adds an offense, and does not correct' do
      expect_offense(<<-RUBY.strip_indent)
        Timecop.foo
        ^^^^^^^ Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY

      expect_no_corrections
    end
  end

  describe 'Timecop' do
    it 'adds an offense, and does not correct' do
      expect_offense(<<-RUBY.strip_indent)
        Timecop
        ^^^^^^^ Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY

      expect_no_corrections
    end
  end

  describe '::Timecop' do
    it 'adds an offense, and does not correct' do
      expect_offense(<<-RUBY.strip_indent)
        ::Timecop
        ^^^^^^^^^ Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY

      expect_no_corrections
    end
  end

  describe 'Foo::Timecop' do
    it 'adds no offenses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Foo::Timecop
      RUBY
    end
  end
end
