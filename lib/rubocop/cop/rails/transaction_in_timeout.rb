# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for transactions wrapped in timeouts,
      # motivated by change in Rails behavior that will
      # cause exited transactions to be rolled back
      # rather than committed (pre Active Record 7.0 behavior).
      #
      # @example
      #   # bad
      #   Timeout.timeout(10) do
      #     ApplicationRecord.transaction do
      #       method_call_that_may_timeout
      #       user.save
      #     end
      #   end
      #
      #   # good
      #   Timeout.timeout(10) do
      #     method_call_that_may_timeout
      #   end
      #   ApplicationRecord.transaction do
      #     user.save
      #   end
      class TransactionInTimeout < Base
        def_node_matcher :timeout_node?, <<~PATTERN
          (block
            (send (const nil? :Timeout) :timeout _ ...)
            ...)
        PATTERN

        MSG = 'Timeouts around transactions may cause unexpected rollbacks.'

        RESTRICT_ON_SEND = %i[transaction].freeze

        def on_send(node)
          return unless node.ancestors.any? { |n| timeout_node?(n) }

          add_offense(node)
        end
      end
    end
  end
end
