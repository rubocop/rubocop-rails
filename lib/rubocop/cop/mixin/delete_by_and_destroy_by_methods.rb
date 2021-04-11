# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for `Rails/DeleteBy` and `Rails/DestroyBy` cops.
    module DeleteByAndDestroyByMethods
      include RangeHelp

      MSG = 'Use `%<preferred_method>s(%<arguments>s)` instead.'

      private

      def register_offense(node, receiver)
        range = range_between(receiver.loc.selector.begin_pos, node.source_range.end_pos)
        arguments = receiver.arguments.map(&:source).join(', ')
        message = format(MSG, preferred_method: preferred_method, arguments: arguments)

        add_offense(range, message: message) do |corrector|
          autocorrect(corrector, node, receiver)
        end
      end

      def autocorrect(corrector, node, receiver)
        corrector.replace(receiver.loc.selector, preferred_method)
        corrector.remove(node.loc.dot)
        corrector.remove(node.loc.selector)
      end
    end
  end
end
