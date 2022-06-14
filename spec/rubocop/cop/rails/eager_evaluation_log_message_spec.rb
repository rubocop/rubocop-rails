# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EagerEvaluationLogMessage, :config do
  it 'registers an offense when passing an interpolated string to Rails.logger.debug' do
    expect_offense(<<~'RUBY')
      Rails.logger.debug "The time is #{Time.now}"
                         ^^^^^^^^^^^^^^^^^^^^^^^^^ Pass a block to `Rails.logger.debug`.
    RUBY

    expect_correction(<<~'RUBY')
      Rails.logger.debug { "The time is #{Time.now}" }
    RUBY
  end

  it 'does not register an offense when passing an interpolated string to Rails.logger.info' do
    expect_no_offenses(<<~'RUBY')
      Rails.logger.info("The time is #{Time.now}")
      Rails.logger.info "The time is #{Time.now}"
    RUBY
  end

  it 'does not register an offense when passing a string to Rails.logger.debug' do
    expect_no_offenses(<<~RUBY)
      Rails.logger.debug('A log message')
      Rails.logger.debug 'A log message'
    RUBY
  end

  it 'does not register an offense when passing an interpolated string in a block to Rails.logger.debug' do
    expect_no_offenses(<<~'RUBY')
      Rails.logger.debug { "The time is #{Time.now}" }
      Rails.logger.debug do
        "The time is #{Time.now}"
      end
    RUBY
  end
end
