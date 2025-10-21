# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for the use of `Class#descendants` which has several issues:
      #
      # 1. It doesn't know about classes that have yet to be autoloaded.
      # 2. It's non-deterministic with regards to Garbage Collection of classes.
      #    If you use `Class.descendants` in tests where there is a pattern to
      #    dynamically define classes, GC is unpredictable for when those classes
      #    are cleaned up and removed.
      #
      #
      # @example
      #   # bad
      #   User.descendants
      #   ApplicationRecord.descendants.map(&:name)
      #
      #   # bad
      #   MyClass.descendants.each do |klass|
      #     klass.do_something
      #   end
      #
      class ClassDescendants < Base
        MSG = 'Avoid using `%<method>s` as it may not include classes that have yet to be autoloaded ' \
              'and is non-deterministic with regards to Garbage Collection.'

        RESTRICT_ON_SEND = %i[descendants].freeze

        # @!method descendants_call?(node)
        def_node_matcher :descendants_call?, <<~PATTERN
          (send _ :descendants ...)
        PATTERN

        def on_send(node)
          return unless descendants_call?(node)

          add_offense(node, message: format(MSG, method: node.method_name))
        end
      end
    end
  end
end
