# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::HelperInstanceVariable do
  subject(:cop) { described_class.new }

  it 'reports uses of instance variables' do
    expect_offense(<<-'RUBY'.strip_indent)
      def welcome_message
        "Hello #{@user.name}"
                 ^^^^^ Do not use instance variables in helpers.
      end
    RUBY
  end

  it 'reports instance variable assignments' do
    expect_offense(<<-RUBY.strip_indent)
      def welcome_message(user)
        @user_name = user.name
        ^^^^^^^^^^ Do not use instance variables in helpers.
      end
    RUBY
  end

  specify do
    expect_no_offenses(<<-'RUBY'.strip_indent)
      def welcome_message(user)
        "Hello #{user.name}"
      end
    RUBY
  end
end
