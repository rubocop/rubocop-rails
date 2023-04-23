# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem 'bump', require: false
gem 'rake'
gem 'rspec'
gem 'rubocop', github: 'rubocop/rubocop'
gem 'rubocop-performance', '~> 1.17.0'
gem 'rubocop-rspec', '~> 2.20.0'
gem 'simplecov'
gem 'test-queue'
gem 'yard', '~> 0.9'

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
