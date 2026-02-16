# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces the use of ActiveRecord calculation methods instead of `pluck`
      # followed by Enumerable methods.
      #
      # It avoids loading potentially many values into memory by doing the
      # calculations inside the database.
      #
      # @example
      #   # bad
      #   User.pluck(:id).max
      #   User.pluck(:id).min
      #   User.pluck(:age).sum
      #
      #   # good
      #   User.maximum(:id)
      #   User.minimum(:id)
      #   User.sum(:age)
      #
      #   # good
      #   User.pluck(:email).max { |email| email.length }
      #   User.pluck(:email).max(2)
      #   User.pluck(:id, :company_id).max
      #   User.pluck(:age).count
      #
      class ActiveRecordCalculation < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Use `%<good_method>s` instead of `pluck.%<bad_method>s`.'

        RESTRICT_ON_SEND = %i[pluck].freeze
        OPERATIONS_MAP = { min: :minimum, max: :maximum, sum: :sum }.freeze

        def_node_matcher :pluck_calculation?, <<~PATTERN
          (send
            (send _ :pluck $_)
            ${:#{OPERATIONS_MAP.keys.join(' :')}})
        PATTERN

        def on_send(node)
          return unless (parent = node.parent)
          return if send_with_block?(parent)

          pluck_calculation?(parent) do |arg_node, calculation|
            good_method = OPERATIONS_MAP.fetch(calculation)
            message = format(MSG, good_method: good_method, bad_method: calculation)
            offense_range = range_between(node.loc.selector.begin_pos, parent.source_range.end_pos)

            add_offense(offense_range, message: message) do |corrector|
              corrector.replace(offense_range, "#{good_method}(#{arg_node.source})")
            end
          end
        end

        private

        def send_with_block?(node)
          node.parent&.block_type? && node.parent.send_node == node
        end
      end
    end
  end
end
