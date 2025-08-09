# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Avoid memoizing `find_by` results with `||=`.
      #
      # It is common to see code that attempts to memoize `find_by` result by `||=`,
      # but `find_by` may return `nil`, in which case it is not memoized as intended.
      #
      # @safety
      #   This cop is unsafe because detected `find_by` may not be Active Record's method,
      #   or the code may have a different purpose than memoization.
      #
      # @example
      #   # bad
      #   def current_user
      #     @current_user ||= User.find_by(id: session[:user_id])
      #   end
      #
      #   # good
      #   def current_user
      #     if instance_variable_defined?(:@current_user)
      #       @current_user
      #     else
      #       @current_user = User.find_by(id: session[:user_id])
      #     end
      #   end
      class FindByOrAssignmentMemoization < Base
        extend AutoCorrector

        MSG = 'Avoid memoizing `find_by` results with `||=`.'

        RESTRICT_ON_SEND = %i[find_by].freeze

        def_node_matcher :find_by_or_assignment_memoization, <<~PATTERN
          (or_asgn
            (ivasgn $_)
            $(send _ :find_by ...)
          )
        PATTERN

        def on_send(node)
          assignment_node = node.parent
          find_by_or_assignment_memoization(assignment_node) do |varible_name, find_by|
            next if assignment_node.each_ancestor(:if).any?

            add_offense(assignment_node) do |corrector|
              corrector.replace(
                assignment_node,
                <<~RUBY.rstrip
                  if instance_variable_defined?(:#{varible_name})
                    #{varible_name}
                  else
                    #{varible_name} = #{find_by.source}
                  end
                RUBY
              )
            end
          end
        end
      end
    end
  end
end
