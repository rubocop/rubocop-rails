# frozen_string_literal: true

# We use ../**/ to match standard Rails directories for Include and Exclude patterns
# ** is necessary to match within packwerk and engine directories.
# .. is necessary to exclude the top level directory (if your project is in /var/app/my_project, for example)
# Rubocop::PathUtil has special handling for .. that makes this work
RSpec.describe 'RuboCop::CLI', :isolated_environment do
  subject(:cli) { RuboCop::CLI.new }

  include_context 'cli spec behavior'

  before do
    RuboCop::ConfigLoader.default_configuration.for_all_cops['SuggestExtensions'] = false
  end

  it 'detects offense when Include matches the path' do
    create_file('.rubocop.yml', <<~YAML)
      Rails/EnvironmentVariableAccess:
        Enabled: true
        Include:
          - '../**/app/**/*.rb'
    YAML

    create_file('app/example.rb', <<~RUBY)
      ENV['RUBY_ENV'] = 'do not set environment variables directly!'
    RUBY

    expect(cli.run(['--only', 'Rails/EnvironmentVariableAccess'])).to eq(1)
    expect($stdout.string).to match('1 offense detected')
  end

  it 'detects offense when Include matches the path when nested in a subdirectory' do
    create_file('.rubocop.yml', <<~YAML)
      Rails/EnvironmentVariableAccess:
        Enabled: true
        Include:
          - '../**/app/**/*.rb'
    YAML

    create_file('packwerk/app/example.rb', <<~RUBY)
      ENV['RUBY_ENV'] = 'do not set environment variables directly!'
    RUBY

    expect(cli.run(['--only', 'Rails/EnvironmentVariableAccess'])).to eq(1)
    expect($stdout.string).to match('1 offense detected')
  end

  it 'does not detect offense when Include does not match the path' do
    create_file('.rubocop.yml', <<~YAML)
      Rails/EnvironmentVariableAccess:
        Enabled: true
        Include:
          - '../**/app/**/*.rb'
    YAML

    create_file('example.rb', <<~RUBY)
      ENV['RUBY_ENV'] = 'do not set environment variables directly!'
    RUBY
    expect(cli.run(['--only', 'Rails/EnvironmentVariableAccess'])).to eq(0)
  end

  it 'does detect offense when the root directory is also in Include' do
    top_level_dir = Pathname.new(Dir.pwd).each_filename.first

    create_file('.rubocop.yml', <<~YAML)
      Rails/EnvironmentVariableAccess:
        Enabled: true
        Include:
          - '../**/#{top_level_dir}/**/*.rb'
    YAML

    create_file(File.join(top_level_dir, 'example.rb'), <<~RUBY)
      ENV['RUBY_ENV'] = 'do not set environment variables directly!'
    RUBY
    expect(cli.run(['--only', 'Rails/EnvironmentVariableAccess'])).to eq(1)
  end

  it 'does not detect offense when the root directory is also in Include, but not in the file path' do
    top_level_dir = Pathname.new(Dir.pwd).each_filename.first

    create_file('.rubocop.yml', <<~YAML)
      Rails/EnvironmentVariableAccess:
        Enabled: true
        Include:
          - '../**/#{top_level_dir}/**/*.rb'
    YAML

    create_file(File.join('example.rb'), <<~RUBY)
      ENV['RUBY_ENV'] = 'do not set environment variables directly!'
    RUBY
    expect(cli.run(['--only', 'Rails/EnvironmentVariableAccess'])).to eq(0)
  end
end
