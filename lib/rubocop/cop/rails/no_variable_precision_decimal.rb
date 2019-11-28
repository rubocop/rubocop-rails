# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks that both precision and scale parameters are defined on
      # columns of datatype decimal.
      #
      # @example
      #   # bad
      #   add_column :fees, :amount, :decimal, scale: 4
      #   add_column :fees, :amount, :decimal, precision: 6
      #   add_column :fees, :amount, :decimal

      #   # good
      #   add_column :fees, :amount, :decimal, precision: 6, scale: 4
      class NoVariablePrecisionDecimal < RuboCop::Cop::Cop
        MSG = 'Set explicit scale and precision when adding Decimal column.'

        def_node_matcher :add_no_precision_decimal_column?, <<-PATTERN
          (send nil? :add_column _ _ _ (hash $...))
        PATTERN

        def_node_matcher :add_no_scale_decimal_column?, <<-PATTERN
          (send nil? :add_column _ _ _ (hash $...))
        PATTERN

        def_node_matcher :precision_option?, <<-PATTERN
          (pair (sym :precision) !nil)
        PATTERN

        def_node_matcher :scale_option?, <<-PATTERN
          (pair (sym :scale) !nil)
        PATTERN

        def on_send(node)
          check_precision_on_decimal_column(node)
          check_scale_on_decimal_column(node)
        end

        private

        def check_precision_on_decimal_column(node)
          pairs = add_no_precision_decimal_column?(node)
          return unless pairs

          precision = pairs.any? { |pair| precision_option?(pair) }
          return if precision

          add_offense(node)
        end

        def check_scale_on_decimal_column(node)
          pairs = add_no_scale_decimal_column?(node)
          return unless pairs

          scale = pairs.find { |pair| scale_option?(pair) }
          return if scale

          add_offense(node)
        end
      end
    end
  end
end
