# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module Rails
    # A plugin that integrates RuboCop Rails with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-rails',
          version: Version::STRING,
          homepage: 'https://github.com/rubocop/rubocop-rails',
          description: 'A RuboCop extension focused on enforcing Rails best practices and coding conventions.'
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        project_root = Pathname.new(__dir__).join('../../..')

        ConfigObsoletion.files << project_root.join('config', 'obsoletion.yml')

        LintRoller::Rules.new(type: :path, config_format: :rubocop, value: project_root.join('config', 'default.yml'))
      end
    end
  end
end
