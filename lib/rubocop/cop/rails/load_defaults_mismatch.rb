# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks that `config.load_defaults` is called with a version that
      # matches the target Rails version.
      #
      # When upgrading Rails, `rails app:update` sets `load_defaults` to the
      # previous Rails version so you can incrementally adopt new defaults.
      # Once the upgrade is complete, `load_defaults` should be updated to
      # match the current Rails version. Not updating the version can mean your app
      # drifts from the newer default configuration, making future upgrades
      # harder.
      #
      # @safety
      #   This cop's offense may be a false positive if you are still
      #   mid-upgrade and have not yet finished adopting the new defaults.
      #
      # @example
      #   # Assuming the project is using Rails 8.1
      #
      #   # bad
      #   config.load_defaults 6.1
      #
      #   # good
      #   config.load_defaults 8.1
      #
      class LoadDefaultsMismatch < Base
        MSG = '`load_defaults` is set to `%<load_version>s` but the target Rails version is `%<rails_version>s`. ' \
              'Update `load_defaults` to match the Rails version after completing the upgrade.'

        RESTRICT_ON_SEND = %i[load_defaults].freeze

        # @!method load_defaults_version(node)
        def_node_matcher :load_defaults_version, <<~PATTERN
          (send _ :load_defaults ${float_type? int_type?})
        PATTERN

        def on_send(node)
          load_defaults_version(node) do |version_node|
            load_version = version_node.value.to_f
            rails_version = target_rails_version

            return unless rails_version

            return if load_version == rails_version

            message = format(MSG, load_version: load_version, rails_version: rails_version)
            add_offense(version_node, message: message)
          end
        end
      end
    end
  end
end
