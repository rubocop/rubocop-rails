# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for Rails/TimeComparison and Rails/TimeComparisonStyle
    module TimeComparisonHelper
      extend NodePattern::Macros

      def_node_matcher :current_time?, <<~PATTERN
        {
          (send (const {nil? cbase} :Time) :current)
          (send (send (const {nil? cbase} :Time) :zone) :now)
        }
      PATTERN

      def_node_matcher :rspec_be?, '(send nil? :be)'

      private

      def register_offense(node, prefer, replacement = prefer)
        add_offense(node, message: format(self.class::MSG, prefer: prefer)) do |corrector|
          corrector.replace(node, replacement) if replacement
        end
      end

      def unwrap(node)
        node = node.children.first while node.begin_type? && node.children.one?
        node
      end

      def arithmetic?(node)
        node = unwrap(node)

        node.send_type? && node.arithmetic_operation?
      end

      # `time&.at < Time.current` raises `NoMethodError` on `nil`, and so does `time&.at.past?`.
      # `Time.current > time&.at` raises `ArgumentError` instead, so it is left alone.
      def safe_navigation?(node)
        while node
          return true if node.csend_type?

          node = node.call_type? ? node.receiver : nil
        end

        false
      end
    end
  end
end
