# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # @example Enabled (default)
      #   # bad
      #   ActiveRecord::Base.transaction do
      #     some_database_stuff
      #   end
      #
      #   # good
      #   ActiveRecord::Base.transaction(requires_new: true) do
      #     some_database_stuff
      #   end
      #
      class TransactionRequiresNew < Base
        extend AutoCorrector
        MSG = 'Always pass "requires_new: true" to transactions.'

        def_node_matcher :transaction?, <<~PATTERN
          (block
            (send _ :transaction ...)
            (args) {_})
        PATTERN

        def_node_matcher :requires_new_argument_passed?, <<~PATTERN
          (block
            (send _ :transaction (hash ... (pair (sym :requires_new) (true) ) ))
            (args) {_})
        PATTERN

        def_node_matcher :arguments_present?, <<~PATTERN
          (block
            (send _ :transaction _+ )
            (args) {_}
          )
        PATTERN

        def on_block(node)
          return unless transaction?(node) && !requires_new_argument_passed?(node)

          if arguments_present?(node)
            add_offense(node)
          else
            add_offense(node) do |corrector|
              corrector.replace(node, node.source.gsub('.transaction', '.transaction(requires_new: true)'))
            end
          end
        end
      end
    end
  end
end
