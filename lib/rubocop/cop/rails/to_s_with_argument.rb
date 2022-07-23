# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Identifies passing any argument to `#to_s`.
      #
      # @safety
      #   This cop is marked as unsafe because it may detect `#to_s` calls
      #   that are not related to Active Support implementation.
      #
      # @example
      #
      #   # bad
      #   obj.to_s(:delimited)
      #
      #   # good
      #   obj.to_formatted_s(:delimited)
      #
      class ToSWithArgument < Base
        extend AutoCorrector
        extend TargetRailsVersion

        MSG = 'Use `to_formatted_s` instead.'

        RESTRICT_ON_SEND = %i[to_s].freeze

        minimum_target_rails_version 7.0

        def on_send(node)
          return if node.arguments.empty?

          add_offense(node.loc.selector) do |corrector|
            corrector.replace(node.loc.selector, 'to_formatted_s')
          end
        end
        alias on_csend on_send
      end
    end
  end
end
