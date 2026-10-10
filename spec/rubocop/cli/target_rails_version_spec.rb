# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI with `AllCops: TargetRailsVersion`', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'cli spec behavior'

  # Another plugin loaded alongside rubocop-rails. It is defined here rather than using a real plugin gem,
  # because the oldest supported RuboCop CI job removes the other plugin gems from the bundle.
  let(:other_plugin_class) do
    Class.new(LintRoller::Plugin) do
      def about
        LintRoller::About.new(name: 'other-plugin', version: '1.0.0', homepage: 'https://example.com',
                              description: 'Another plugin.')
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(type: :object, config_format: :rubocop, value: {})
      end
    end
  end

  let(:other_plugin) do
    <<~YAML.chomp
      - other-plugin:
          require_path: ./other_plugin.rb
          plugin_class_name: OtherPlugin
    YAML
  end

  before do
    stub_const('OtherPlugin', other_plugin_class)
    create_empty_file('other_plugin.rb')

    create_file('example.rb', <<~RUBY)
      # frozen_string_literal: true

      User.where(id: 1).pluck(:name).first
    RUBY
  end

  shared_examples 'accepts `TargetRailsVersion` without a warning' do
    it 'does not warn about `TargetRailsVersion`' do
      create_file('.rubocop.yml', <<~YAML)
        plugins:
        #{plugins.gsub(/^/, '  ')}

        AllCops:
          TargetRailsVersion: 7.1
          SuggestExtensions: false
          NewCops: disable
      YAML

      expect(cli.run(['--only', 'Rails/Pick', 'example.rb'])).to eq(1)
      expect($stderr.string.include?('does not support TargetRailsVersion parameter')).to be(false)
      expect($stdout.string.include?('Rails/Pick: Prefer pick(:name) over pluck(:name).first.')).to be(true)
    end
  end

  context 'with only rubocop-rails' do
    let(:plugins) { '- rubocop-rails' }

    it_behaves_like 'accepts `TargetRailsVersion` without a warning'
  end

  context 'with another plugin loaded after rubocop-rails' do
    let(:plugins) { "- rubocop-rails\n#{other_plugin}" }

    it_behaves_like 'accepts `TargetRailsVersion` without a warning'
  end

  context 'with another plugin loaded before rubocop-rails' do
    let(:plugins) { "#{other_plugin}\n- rubocop-rails" }

    it_behaves_like 'accepts `TargetRailsVersion` without a warning'
  end
end
