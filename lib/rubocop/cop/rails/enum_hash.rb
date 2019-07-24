# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for enums written with array syntax.
      #
      # When using array syntax, adding an element in a
      # position other than the last causes all previous
      # definitions to shift. Explicitly specifying the
      # value for each key prevents this from happening.
      #
      # @example
      #   # bad
      #   enum status: [:active, :archived]
      #
      #   # good
      #   enum status: { active: 0, archived: 1 }
      #
      class EnumHash < Cop
        MSG = 'Enum defined as an array found in `%<enum>s` enum declaration. '\
              'Use hash syntax instead.'

        def_node_matcher :enum_with_array?, <<~PATTERN
          (send nil? :enum (hash (pair (_ $_) array)))
        PATTERN

        def on_send(node)
          enum_with_array?(node) do |name|
            add_offense(node, message: format(MSG, enum: name))
          end
        end
      end
    end
  end
end
