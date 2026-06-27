# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem 'bump', require: false
# Avoid i18n 1.15.0, which breaks on Ruby 3.1 (ruby-i18n/i18n#735).
gem 'i18n', '!= 1.15.0'
gem 'irb'
gem 'rake'
# FIXME: rdoc 8.0+ depends on rbs, whose released C extension fails to build on JRuby.
# rbs 4.1.0.pre.2 ships a `java` platform gem that works on JRuby, so pin to it there
# until a stable release that supports JRuby ships.
# https://github.com/ruby/rdoc/issues/1746
gem 'rbs', '4.1.0.pre.2' if RUBY_ENGINE == 'jruby'
gem 'rspec'
gem 'rubocop', github: 'rubocop/rubocop'
gem 'rubocop-performance', '~> 1.24.0'
gem 'rubocop-rspec', '~> 3.9.0'
gem 'simplecov'
gem 'test-queue'
gem 'yard', '~> 0.9'

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
