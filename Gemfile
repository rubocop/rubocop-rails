# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem 'bump', require: false
# FIXME: Remove when the next prism version is released.
gem 'prism', '< 1.5.0' if RUBY_VERSION < '3.0' || RUBY_ENGINE == 'jruby'
gem 'rake'
gem 'rspec'
gem 'rubocop', github: 'rubocop/rubocop'
gem 'rubocop-performance', '~> 1.24.0'
gem 'rubocop-rspec', '~> 3.3.0'
gem 'simplecov'
gem 'test-queue'
gem 'yard', '~> 0.9'

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
