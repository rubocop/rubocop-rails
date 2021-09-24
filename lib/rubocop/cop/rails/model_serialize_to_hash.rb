# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of the serialize Hash macro.
      #
      # @example
      #   # bad
      #   # serialize :params, Hash
      #
      #   # good
      #   # serialize :params, JSON
      class ModelSerializeToHash < Base
        MSG = 'Prefer saving parameters to JSON or manual, if possible.'
        RESTRICT_ON_SEND = %i[serialize].freeze

        def_node_matcher :serializable_hash?, <<~PATTERN
          (send nil? :serialize (sym _) (const nil? :Hash))
        PATTERN

        def on_send(node)
          return unless serializable_hash?(node)

          add_offense(node)
        end
      end
    end
  end
end
