# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem 'bump', require: false
gem 'rake'
gem 'rspec'
gem 'rubocop', github: 'rubocop/rubocop'
gem 'rubocop-performance', '~> 1.18.0'
gem 'rubocop-rspec', '~> 2.25.0'
gem 'simplecov'
gem 'test-queue'
gem 'yard', '~> 0.9'

group :test do
  # FIXME: This is a workaround for installation error of BigDecimal 3.1.5 in JRuby:
  #
  # ```
  # Installing bigdecimal 3.1.5 with native extensions
  # Gem::Ext::BuildError: ERROR: Failed to build gem native extension.
  # ```
  #
  # https://github.com/rubocop/rubocop-rails/actions/runs/7192052922/job/19587776909
  #
  # See: https://github.com/ruby/bigdecimal/issues/279
  gem 'bigdecimal', '< 3.1.5', platform: :jruby
end

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
