# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI --autocorrect', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'cli spec behavior'

  before do
    RuboCop::ConfigLoader.default_configuration.for_all_cops['SuggestExtensions'] = false
  end

  it 'corrects `Rails/EagerEvaluationLogMessage,` with `Style/MethodCallWithArgsParentheses`' do
    create_file('.rubocop.yml', <<~YAML)
      Rails/SafeNavigation:
        ConvertTry: true
    YAML

    create_file('example.rb', <<~'RUBY')
      Rails.logger.debug "foo#{bar}"
    RUBY

    expect(cli.run(['-a', '--only', 'Rails/EagerEvaluationLogMessage,Style/MethodCallWithArgsParentheses'])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~'RUBY')
      Rails.logger.debug { "foo#{bar}" }
    RUBY
  end

  it 'corrects `Rails/SafeNavigation` with `Style/RedundantSelf`' do
    create_file('.rubocop.yml', <<~YAML)
      Rails/SafeNavigation:
        ConvertTry: true
    YAML

    create_file('example.rb', <<~RUBY)
      self.try(:bar).try(:baz)
    RUBY

    expect(cli.run(['-a', '--only', 'Rails/SafeNavigation,Style/RedundantSelf'])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      self&.bar&.baz
    RUBY
  end
end
