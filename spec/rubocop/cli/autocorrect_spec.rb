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

  it 'corrects `Rails/NegateInclude,` with `Style/InverseMethods`' do
    create_file('example.rb', <<~RUBY)
      array.select { |item| !do_something.include?(item) }
    RUBY

    expect(cli.run(['-A', '--only', 'Rails/NegateInclude,Style/InverseMethods'])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      array.reject { |item| do_something.include?(item) }
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

  it 'corrects `Style/HashExcept` with `TargetRubyVersion: 2.0`' do
    create_file('.rubocop.yml', <<~YAML)
      AllCops:
        TargetRubyVersion: 2.0
    YAML

    create_file('example.rb', <<~RUBY)
      {foo: 1, bar: 2, baz: 3}.reject {|k, v| k == :bar }
    RUBY

    expect(cli.run(['-A', '--only', 'Style/HashExcept'])).to eq(0)
    expect(File.read('example.rb')).to eq(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.except(:bar)
    RUBY
  end
end
