# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cops looks for assignments of `ignored_columns` that override previous
      # assignments.
      #
      # Overwriting previous assignments is usually a mistake, since it will
      # un-ignore the first set of columns
      #
      # @example
      #
      #   # bad
      #   class User < ActiveRecord::Base
      #     self.ignored_columns = [:one]
      #     self.ignored_columns = [:two]
      #   end
      #
      #   # bad
      #   class User < ActiveRecord::Base
      #     self.ignored_columns += [:one]
      #     self.ignored_columns = [:two]
      #   end
      #
      #   # good
      #   class User < ActiveRecord::Base
      #     self.ignored_columns = [:one, :two]
      #   end
      #
      #   # good
      #   class User < ActiveRecord::Base
      #     self.ignored_columns = [:one]
      #     self.ignored_columns += [:two]
      #   end
      #
      class DuplicateIgnoredColumns < Base
        MSG = 'This assignment to `ignored_columns` overwrites previous ones.'

        def_node_matcher :ignored_columns_assign, <<-PATTERN
          (send self :ignored_columns= ...)
        PATTERN
        def_node_matcher :ignored_columns_append, <<-PATTERN
          (op-asgn
            (send self :ignored_columns)
            :+ ...
          )
        PATTERN

        def on_op_asgn(node)
          ignored_columns_append(node) do
            @seen_before = true
          end
        end

        def on_send(node)
          ignored_columns_assign(node) do
            add_offense(node.loc.selector) if @seen_before
            @seen_before = true
          end
        end

        def on_new_investigation
          @seen_before = false
          super
        end
      end
    end
  end
end
