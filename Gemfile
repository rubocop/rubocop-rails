# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem 'bump', require: false
# Avoid i18n 1.15.0, which breaks on Ruby 3.1 (ruby-i18n/i18n#735).
gem 'i18n', '!= 1.15.0'
gem 'irb'
gem 'rake'
gem 'rspec'
gem 'rubocop', github: 'rubocop/rubocop'
gem 'rubocop-performance', '~> 1.24.0'
gem 'rubocop-rspec', '~> 3.9.0'
gem 'simplecov'
gem 'test-queue'
gem 'yard', '~> 0.9'

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
