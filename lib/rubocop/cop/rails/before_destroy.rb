# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for a `before_destroy` callback that don't
      # specify a `:prepend` option.
      #
      # @example
      #   # bad
      #   class Letter < ActiveRecord::Base
      #     before_destroy :read?
      #   end
      #
      #   # good
      #   class Letter < ActiveRecord::Base
      #     before_destroy :read?, prepend: true
      #   end
      class BeforeDestroy < Cop
        MSG = 'Specify a `:prepend` option.'

        def_node_matcher :before_destroy_without_options?, <<~PATTERN
          (send nil? :before_destroy _)
        PATTERN

        def_node_matcher :before_destroy_with_options?, <<~PATTERN
          (send nil? :before_destroy _ (hash $...))
        PATTERN

        def_node_matcher :prepend_option_is_true?, <<~PATTERN
          (pair (sym :prepend) true)
        PATTERN

        def on_send(node)
          return unless node.command?(:before_destroy)
          return if before_destroy_has_valid_options?(node)

          add_offense(node, location: :selector)
        end

        private

        def before_destroy_has_valid_options?(node)
          options = before_destroy_with_options?(node)
          return true if options && valid_options?(options)

          return false if before_destroy_without_options?(node)

          false
        end

        def valid_options?(options)
          options.any? { |o| prepend_option_is_true?(o) }
        end
      end
    end
  end
end
