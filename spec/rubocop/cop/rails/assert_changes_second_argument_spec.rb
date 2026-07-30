# frozen_string_literal: true

RSpec.describe(RuboCop::Cop::Rails::AssertChangesSecondArgument, :config) do
  let(:message) do
    'Use assert_changes to assert when an expression changes from and to specific values. ' \
      'Use assert_difference instead to assert when an expression changes by a specific delta. ' \
      'The second argument to assert_changes is the message emitted on assert failure.'
  end

  describe('offenses') do
    it 'adds offense when the second positional argument is an integer' do
      expect_offense(<<~RUBY)
        assert_changes @value, -1 do
        ^^^^^^^^^^^^^^ #{message}
          @value += 1
        end
      RUBY
    end

    it 'adds offense when the second positional argument is a float' do
      expect_offense(<<~RUBY)
        assert_changes @value, -1.0 do
        ^^^^^^^^^^^^^^ #{message}
          @value += 1
        end
      RUBY
    end

    it 'does not add offense when the second argument is a string' do
      expect_no_offenses(<<~RUBY)
        assert_changes @value, "Value should change" do
          @value += 1
        end
      RUBY
    end

    it 'does not add offense when the second argument is an interpolated string' do
      expect_no_offenses(<<~RUBY)
        assert_changes @value, "\#{thing} should change" do
          @value += 1
        end
      RUBY
    end

    it 'does not add offense when the second argument is a symbol' do
      expect_no_offenses(<<~RUBY)
        assert_changes @value, :should_change do
          @value += 1
        end
      RUBY
    end

    it 'does not add offense when the second argument is an interpolated symbol' do
      expect_no_offenses(<<~RUBY)
        assert_changes @value, :"\#{thing}_should_change" do
          @value += 1
        end
      RUBY
    end

    it 'does not add offense when the second argument is a variable' do
      expect_no_offenses(<<~RUBY)
        message = "Value should change"
        assert_changes @value, message do
          @value += 1
        end
      RUBY
    end

    it 'does not add offense when there is only one argument' do
      expect_no_offenses(<<~RUBY)
        assert_changes @value do
          @value += 1
        end
      RUBY
    end

    it 'does not add offense when there is only one positional argument' do
      expect_no_offenses(<<~RUBY)
        assert_changes @value, from: 0 do
          @value += 1
        end
      RUBY
    end

    it 'does not add offense on other methods' do
      expect_no_offenses(<<~RUBY)
        assert_difference @value, "Value should change" do
          @value += 1
        end
      RUBY
    end
  end

  describe('autocorrect') do
    it 'autocorrects method from assert_changes to assert_difference' do
      source = <<-RUBY
        assert_changes @value, -1.0 do
          @value += 1
        end
      RUBY

      corrected_source = <<-RUBY
        assert_difference @value, -1.0 do
          @value += 1
        end
      RUBY

      expect(autocorrect_source(source)).to(eq(corrected_source))
    end
  end
end
