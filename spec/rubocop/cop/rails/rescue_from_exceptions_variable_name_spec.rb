# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RescueFromExceptionsVariableName, :config do
  subject(:cop) { described_class.new(config) }

  it 'does not register an offense without variable' do
    expect_no_offenses(<<~RUBY)
      rescue_from MyException do
        # do something
      end
    RUBY
  end

  context 'with default config' do
    context 'with default variable' do
      it 'does not register an offense with a single rescued exception' do
        expect_no_offenses(<<~RUBY)
          rescue_from MyException do |e|
            # do something
          end
        RUBY
      end

      it 'does not register an offense with multiple rescued exceptions' do
        expect_no_offenses(<<~RUBY)
          rescue_from MyException, MyOtherException do |e|
            # do something
          end
        RUBY
      end

      it 'does not register an offense with underscored prefix variable' do
        expect_no_offenses(<<~RUBY)
          rescue_from MyException do |_e|
            # do something
          end
        RUBY
      end

      it 'does not register an offense using splat operator' do
        expect_no_offenses(<<~RUBY)
          rescue_from *handled do |e|
            # do something
          end
        RUBY
      end
    end

    context 'when using another variable' do
      it 'registers an offense with a single rescued exception' do
        expect_offense(<<~RUBY)
          rescue_from MyException do |exception|
                                     ^^^^^^^^^^^ Use `e` instead of `exception`.
            # do something
          end
        RUBY

        expect_correction(<<~RUBY)
          rescue_from MyException do |e|
            # do something
          end
        RUBY
      end

      it 'registers an offense with multiple rescued exceptions' do
        expect_offense(<<~RUBY)
          rescue_from MyException, MyOtherException do |exception|
                                                       ^^^^^^^^^^^ Use `e` instead of `exception`.
            # do something
          end
        RUBY

        expect_correction(<<~RUBY)
          rescue_from MyException, MyOtherException do |e|
            # do something
          end
        RUBY
      end

      it 'registers an offense with underscored prefix variable' do
        expect_offense(<<~RUBY)
          rescue_from MyException do |_exception|
                                     ^^^^^^^^^^^^ Use `_e` instead of `_exception`.
            # do something
          end
        RUBY

        expect_correction(<<~RUBY)
          rescue_from MyException do |_e|
            # do something
          end
        RUBY
      end

      it 'registers an offense using splat operator' do
        expect_offense(<<~RUBY)
          rescue_from *handled do |exception|
                                  ^^^^^^^^^^^ Use `e` instead of `exception`.
            # do something
          end
        RUBY

        expect_correction(<<~RUBY)
          rescue_from *handled do |e|
            # do something
          end
        RUBY
      end
    end
  end

  context 'with the `PreferredName` setup' do
    let(:cop_config) do
      {
        'PreferredName' => 'exception'
      }
    end

    it 'does not register an offense when using the preferred name' do
      expect_no_offenses(<<~RUBY)
        rescue_from MyException do |exception|
          # do something
        end
      RUBY
    end

    it 'does not register an offense when using the preferred name with' \
       'multiple rescued exceptions' do
      expect_no_offenses(<<~RUBY)
        rescue_from MyException, MyOtherException do |exception|
          # do something
        end
      RUBY
    end

    it 'registers an offense when using another name' do
      expect_offense(<<~RUBY)
        rescue_from MyException do |e|
                                   ^^^ Use `exception` instead of `e`.
          # do something
        end
      RUBY

      expect_correction(<<~RUBY)
        rescue_from MyException do |exception|
          # do something
        end
      RUBY
    end

    it 'registers an offense with underscored prefix variable' do
      expect_offense(<<~RUBY)
        rescue_from MyException do |_e|
                                   ^^^^ Use `_exception` instead of `_e`.
          # do something
        end
      RUBY

      expect_correction(<<~RUBY)
        rescue_from MyException do |_exception|
          # do something
        end
      RUBY
    end
  end
end
