# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Rails
      # TODO: Write cop description and example of bad / good code. For every
      # `SupportedStyle` and unique configuration, there needs to be examples.
      # Examples must have valid Ruby syntax. Do not use upticks.
      #
      # @example EnforcedStyle: bar (default)
      #   # Description of the `bar` style.
      #
      #   # bad
      #   bad_bar_method
      #
      #   # bad
      #   bad_bar_method(args)
      #
      #   # good
      #   good_bar_method
      #
      #   # good
      #   good_bar_method(args)
      #
      # @example EnforcedStyle: foo
      #   # Description of the `foo` style.
      #
      #   # bad
      #   bad_foo_method
      #
      #   # bad
      #   bad_foo_method(args)
      #
      #   # good
      #   good_foo_method
      #
      #   # good
      #   good_foo_method(args)
      #
      class BeforeDestroy < Cop
        # TODO: Implement the cop in here.
        #
        # In many cases, you can use a node matcher for matching node pattern.
        # See https://github.com/rubocop-hq/rubocop-ast/blob/master/lib/rubocop/node_pattern.rb
        #
        # For example
        MSG = 'TEST TEST'

        def_node_matcher :before_destroy?, <<~PATTERN
          (send _ :before_destroy)
        PATTERN

        def_node_search :associations_with_dependent_destroy, <<~PATTERN
          (send nil? {:has_many :has_one} _ (hash $...))
        PATTERN

        def_node_matcher :dependent_destroy, <<~PATTERN
          (pair (sym :dependent) (sym :destroy))
        PATTERN

        def_node_matcher :prepend_true, <<~PATTERN
          (pair (sym :prepend) true)
        PATTERN

        def on_send(node)
          return unless before_destroy?(node)

          root_class_node = node.each_ancestor(:class).first
          add_offense(node) if check_associations(root_class_node)
        end

        private

        def check_associations(root_class_node)
          associations_with_dependent_destroy(root_class_node).each do |association_options|
            next if association_options.empty?

            has_dependent_destroy = association_options.any?(&method(:dependent_destroy))
            has_prepend_true = association_options.any?(&method(:prepend_true))
            return true if has_dependent_destroy && !has_prepend_true
          end

          false
        end
      end
    end
  end
end
