# frozen_string_literal: true

# For code coverage measurements to work properly, `SimpleCov` should be loaded
# and started before any application code is loaded.
if ENV.fetch('COVERAGE', nil) == 'true'
  require 'simplecov'
  SimpleCov.start
end

require 'rubocop-rails'
require 'rubocop/rspec/support'
require_relative 'support/file_helper'
require_relative 'support/shared_contexts'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.filter_run_excluding broken_on: :prism if ENV['PARSER_ENGINE'] == 'parser_prism'

  # Prism supports Ruby 3.3+ parsing.
  config.filter_run_excluding unsupported_on: :prism if ENV['PARSER_ENGINE'] == 'parser_prism'

  # With whitequark/parser, RuboCop supports Ruby syntax compatible with 2.0 to 3.3.
  config.filter_run_excluding unsupported_on: :parser if ENV['PARSER_ENGINE'] != 'parser_prism'

  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.order = :random
  Kernel.srand config.seed
end
