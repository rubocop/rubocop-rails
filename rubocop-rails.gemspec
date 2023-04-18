# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'rubocop/rails/version'
require 'English'

Gem::Specification.new do |s|
  s.name = 'rubocop-rails'
  s.version = RuboCop::Rails::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.7.0'
  s.authors = ['Bozhidar Batsov', 'Jonas Arvidsson', 'Yuji Nakayama']
  s.description = <<~DESCRIPTION
    Automatic Rails code style checking tool.
    A RuboCop extension focused on enforcing Rails best practices and coding conventions.
  DESCRIPTION

  s.email = 'rubocop@googlegroups.com'
  s.files = Dir['LICENSE.txt', 'README.md', 'config/**/*', 'lib/**/*']
  s.extra_rdoc_files = ['LICENSE.txt', 'README.md']
  s.homepage = 'https://github.com/rubocop/rubocop-rails'
  s.licenses = ['MIT']
  s.summary = 'Automatic Rails code style checking tool.'

  s.metadata = {
    'homepage_uri' => 'https://docs.rubocop.org/rubocop-rails/',
    'changelog_uri' => 'https://github.com/rubocop/rubocop-rails/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/rubocop/rubocop-rails/',
    'documentation_uri' => "https://docs.rubocop.org/rubocop-rails/#{RuboCop::Rails::Version.document_version}/",
    'bug_tracker_uri' => 'https://github.com/rubocop/rubocop-rails/issues',
    'rubygems_mfa_required' => 'true'
  }

  s.add_runtime_dependency 'activesupport', '>= 4.2.0'
  # Rack::Utils::SYMBOL_TO_STATUS_CODE, which is used by HttpStatus cop, was
  # introduced in rack 1.1
  s.add_runtime_dependency 'rack', '>= 1.1'
  s.add_runtime_dependency 'rubocop', '>= 1.33.0', '< 2.0'
end
