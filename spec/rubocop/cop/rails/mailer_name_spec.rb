# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::MailerName, :config do
  [
    '::ActionMailer::Base',
    '::ApplicationMailer',
    'ActionMailer::Base',
    'ApplicationMailer'
  ].each do |base|
    context 'when regular class definition' do
      it 'registers an offense and corrects when name without suffix' do
        expect_offense(<<~RUBY)
          class User < #{base}
                ^^^^ Mailer should end with `Mailer` suffix.
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserMailer < #{base}
          end
        RUBY
      end

      it 'does not register an offense when name with suffix' do
        expect_no_offenses(<<~RUBY)
          class UserMailer < #{base}
          end
        RUBY
      end
    end

    context 'when `Class.new` definition' do
      it 'registers an offense and corrects when name without suffix' do
        expect_offense(<<~RUBY)
          User = Class.new(#{base})
          ^^^^ Mailer should end with `Mailer` suffix.
        RUBY

        expect_correction(<<~RUBY)
          UserMailer = Class.new(#{base})
        RUBY
      end

      it 'does not register an offense when name with suffix' do
        expect_no_offenses(<<~RUBY)
          UserMailer = Class.new(#{base})
        RUBY
      end
    end

    context 'when `::Class.new` definition' do
      it 'registers an offense and corrects when name without suffix' do
        expect_offense(<<~RUBY)
          User = ::Class.new(#{base})
          ^^^^ Mailer should end with `Mailer` suffix.
        RUBY

        expect_correction(<<~RUBY)
          UserMailer = ::Class.new(#{base})
        RUBY
      end

      it 'does not register an offense when name with suffix' do
        expect_no_offenses(<<~RUBY)
          UserMailer = ::Class.new(#{base})
        RUBY
      end
    end
  end
end
