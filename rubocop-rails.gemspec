# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'rubocop/rails/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |s|
  s.name = 'rubocop-rails'
  s.version = RuboCop::Rails::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.3.0'
  s.authors = ['Bozhidar Batsov', 'Jonas Arvidsson', 'Yuji Nakayama']
  s.description = <<-DESCRIPTION
    Automatic Rails code style checking tool.
    A RuboCop extension focused on enforcing Rails best practices and coding conventions.
  DESCRIPTION

  s.email = 'rubocop@googlegroups.com'
  s.files = `git ls-files bin config lib LICENSE.txt README.md`
            .split($RS)
  s.extra_rdoc_files = ['LICENSE.txt', 'README.md']
  s.homepage = 'https://github.com/rubocop-hq/rubocop-rails'
  s.licenses = ['MIT']
  s.summary = 'Automatic Rails code style checking tool.'

  s.metadata = {
    'homepage_uri' => 'https://github.com/rubocop-hq/rubocop-rails/',
    'changelog_uri' => 'https://github.com/rubocop-hq/rubocop-rails/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/rubocop-hq/rubocop-rails/',
    'documentation_uri' => 'https://rubocop.readthedocs.io/',
    'bug_tracker_uri' => 'https://github.com/rubocop-hq/rubocop-rails/issues'
  }

  s.add_runtime_dependency 'rack', '>= 2.0'
  s.add_runtime_dependency 'rubocop', '>= 0.58.0'
end
# rubocop:enable Metrics/BlockLength
