# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for `before_destroy` callbacks that don't
      # specify a `:prepend` option.
      #
      # @example
      #   # bad
      #   class Letter < ActiveRecord::Base
      #     before_destroy :read?
      #   end
      #
      #   # bad
      #   class Letter < ActiveRecord::Base
      #     before_destroy do
      #     end
      #   end
      #
      #   # good
      #   class Letter < ActiveRecord::Base
      #     before_destroy :read?, prepend: true
      #   end
      #
      #   # good
      #   class Letter < ActiveRecord::Base
      #     before_destroy prepend: true do
      #     end
      #   end
      class BeforeDestroy < Cop
        MSG = 'Specify a `:prepend` option.'

        def_node_matcher :before_destroy_with_prepend?, <<~PATTERN
          (send nil? :before_destroy sym ? (hash <(pair (sym :prepend) true) ...>))
        PATTERN

        def on_send(node)
          return unless node.command?(:before_destroy)
          return if before_destroy_with_prepend?(node)

          add_offense(node, location: :selector)
        end
      end
    end
  end
end
