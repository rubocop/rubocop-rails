# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks misuse of the second argument to ActiveSupport `assert_changes` method
      #
      # `assert_changes`'s second argument is the failure message emitted when the
      # first argument (expression) is unchanged in the block.
      #
      # A common mistake is to use `assert_changes` with the expected change
      # value delta as the second argument.
      # In that case `assert_changes` will validate only that the expression changes,
      # not that it changes by a specific value.
      #
      # Users should provide the 'from' and 'to' parameters,
      # or use `assert_difference` instead, which does support deltas.
      #
      # @example
      #
      #   # bad
      #   assert_changes -> { @value }, 1 do
      #     @value += 1
      #   end
      #
      #   # good
      #   assert_changes -> { @value }, from: 0, to: 1 do
      #     @value += 1
      #   end
      #   assert_changes -> { @value }, "Value should change" do
      #     @value += 1
      #   end
      #   assert_difference -> { @value }, 1 do
      #     @value += 1
      #   end
      #
      class AssertChangesSecondArgument < Base
        extend AutoCorrector

        MSG = 'Use assert_changes to assert when an expression changes from and to specific values. ' \
              'Use assert_difference instead to assert when an expression changes by a specific delta. ' \
              'The second argument to assert_changes is the message emitted on assert failure.'

        def on_send(node)
          return if node.receiver || !node.method?(:assert_changes)
          return if node.arguments[1].nil?

          return unless offense?(node.arguments[1])

          add_offense(node.loc.selector) do |corrector|
            corrector.replace(node.loc.selector, 'assert_difference')
          end
        end

        private

        def offense?(arg)
          !arg.hash_type? && !arg.str_type? && !arg.dstr_type? && !arg.sym_type? && !arg.dsym_type? && !arg.variable?
        end
      end
    end
  end
end
