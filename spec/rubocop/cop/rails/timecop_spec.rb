# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Timecop, :config do
  shared_examples 'adds an offense to constant, and does not correct' do |usage:|
    constant = usage.include?('::Timecop') ? '::Timecop' : 'Timecop'

    it 'adds an offense, and does not correct' do
      expect_offense(<<~RUBY, constant: constant)
        #{usage}
        ^{constant} Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY

      expect_no_corrections
    end
  end

  describe 'Timecop' do
    include_examples 'adds an offense to constant, and does not correct', usage: 'Timecop'

    describe '.*' do
      include_examples 'adds an offense to constant, and does not correct', usage: 'Timecop.foo'
    end

    shared_examples 'adds an offense to send, and does not correct' do |usage:, include_time_flow_addendum: false|
      usage_without_arguments = usage.sub(/\(.*\)$/, '')
      addendum =
        include_time_flow_addendum ? '. If you need time to keep flowing, simulate it by travelling again.' : ''

      context 'given no block' do
        it 'adds an offense, and does not correct' do
          expect_offense(<<~RUBY, usage: usage)
            #{usage}
            ^{usage} Use `travel` or `travel_to` instead of `#{usage_without_arguments}`#{addendum}
          RUBY

          expect_no_corrections
        end
      end

      context 'given a block' do
        it 'adds an offense, and does not correct' do
          expect_offense(<<~RUBY, usage: usage)
            #{usage} { assert true }
            ^{usage} Use `travel` or `travel_to` instead of `#{usage_without_arguments}`#{addendum}
          RUBY

          expect_no_corrections
        end
      end
    end

    describe '.freeze' do
      context 'without arguments' do
        shared_examples 'adds an offense and corrects to' do |replacement:|
          context 'given no block' do
            it "adds an offense, and corrects to `#{replacement}`" do
              expect_offense(<<~RUBY)
                Timecop.freeze
                ^^^^^^^^^^^^^^ Use `#{replacement}` instead of `Timecop.freeze`
              RUBY

              expect_correction(<<~RUBY)
                #{replacement}
              RUBY
            end
          end

          context 'given a block' do
            it "adds an offense, and corrects to `#{replacement}`" do
              expect_offense(<<~RUBY)
                Timecop.freeze { assert true }
                ^^^^^^^^^^^^^^ Use `#{replacement}` instead of `Timecop.freeze`
              RUBY

              expect_correction(<<~RUBY)
                #{replacement} { assert true }
              RUBY
            end
          end
        end

        context 'prior to Rails 5.2', :rails51 do
          include_examples 'adds an offense and corrects to', replacement: 'travel_to(Time.now)'
        end

        context 'since Rails 5.2', :rails52 do
          include_examples 'adds an offense and corrects to', replacement: 'freeze_time'
        end
      end

      context 'with arguments' do
        include_examples 'adds an offense to send, and does not correct', usage: 'Timecop.freeze(*time_args)'
      end
    end

    describe '.return' do
      shared_examples 'prefers' do |replacement|
        context 'given no block' do
          it "adds an offense, and corrects to `#{replacement}`" do
            expect_offense(<<~RUBY)
              Timecop.return
              ^^^^^^^^^^^^^^ Use `#{replacement}` instead of `Timecop.return`
            RUBY

            expect_correction(<<~RUBY)
              #{replacement}
            RUBY
          end

          context 'inside a block' do
            it "adds an offense, and corrects to `#{replacement}`" do
              expect_offense(<<~RUBY)
                foo { Timecop.return }
                      ^^^^^^^^^^^^^^ Use `#{replacement}` instead of `Timecop.return`
              RUBY

              expect_correction(<<~RUBY)
                foo { #{replacement} }
              RUBY
            end
          end
        end

        context 'given a block' do
          it 'adds an offense, and does not correct' do
            expect_offense(<<~RUBY)
              Timecop.return { assert true }
              ^^^^^^^^^^^^^^ Use `#{replacement}` instead of `Timecop.return`
            RUBY

            expect_no_corrections
          end

          context 'inside a block' do
            it 'adds an offense, and does not correct' do
              expect_offense(<<~RUBY)
                foo { Timecop.return { assert true } }
                      ^^^^^^^^^^^^^^ Use `#{replacement}` instead of `Timecop.return`
              RUBY

              expect_no_corrections
            end
          end
        end
      end

      context 'prior to Rails < 6.0', :rails52 do
        include_examples 'prefers', 'travel_back'
      end

      context 'since Rails 6.0', :rails60 do
        include_examples 'prefers', 'unfreeze_time'
      end
    end

    describe '.scale' do
      include_examples 'adds an offense to send, and does not correct', usage: 'Timecop.scale(factor)',
                                                                        include_time_flow_addendum: true
    end

    describe '.travel' do
      include_examples 'adds an offense to send, and does not correct', usage: 'Timecop.travel(*time_args)',
                                                                        include_time_flow_addendum: true
    end
  end

  describe '::Timecop' do
    include_examples 'adds an offense to constant, and does not correct', usage: '::Timecop'
  end

  describe 'Foo::Timecop' do
    it 'adds no offenses' do
      expect_no_offenses(<<~RUBY)
        Foo::Timecop
      RUBY
    end
  end
end
