# frozen_string_literal: true

require 'bundler'
require 'bundler/gem_tasks'

Dir['tasks/**/*.rake'].each { |t| load t }

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

task default: %i[
  documentation_syntax_check
  generate_cops_documentation
  spec
]
