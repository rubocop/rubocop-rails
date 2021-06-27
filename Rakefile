# frozen_string_literal: true

task release: 'changelog:check_clean' # Before task is required

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

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

desc 'Run RSpec'
task :spec do
  if Process.respond_to?(:fork)
    sh('rspec-queue spec')
  else
    sh('rspec spec')
  end
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

desc 'Run RuboCop over itself'
RuboCop::RakeTask.new(:internal_investigation).tap do |task|
  if RUBY_ENGINE == 'ruby' &&
     RbConfig::CONFIG['host_os'] !~ /mswin|msys|mingw|cygwin|bccwin|wince|emc/
    task.options = %w[--parallel]
  end
end

task default: %i[
  documentation_syntax_check
  generate_cops_documentation
  spec
  internal_investigation
]

desc 'Generate a new cop template'
task :new_cop, [:cop] do |_task, args|
  require 'rubocop'

  cop_name = args.fetch(:cop) do
    warn 'usage: bundle exec rake new_cop[Rails/Name]'
    exit!
  end

  github_user = `git config github.user`.chop
  github_user = 'your_id' if github_user.empty?

  generator = RuboCop::Cop::Generator.new(cop_name, github_user)

  generator.write_source
  generator.write_spec
  generator.inject_require(
    root_file_path: 'lib/rubocop/cop/rails_cops.rb'
  )
  generator.inject_config(config_file_path: 'config/default.yml', version_added: bump_minor_version)

  puts generator.todo
end

def bump_minor_version
  major, minor, _patch = RuboCop::Rails::Version::STRING.split('.')

  "#{major}.#{minor.succ}"
end
