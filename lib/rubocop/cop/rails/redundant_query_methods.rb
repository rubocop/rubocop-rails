# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for Active Record query methods called more than once in the same
      # chain with the same arguments.
      #
      # Repeating any of these with equal arguments builds the same relation as
      # calling it once: the values are merged into a set, so the generated SQL
      # is unchanged and the extra call only obscures the query.
      #
      # Repeating one with *different* arguments is not redundant and is never
      # registered, because those calls combine: `order(:rank).order(:title)`
      # sorts by `title` within `rank`, and `select(:id).select(:title)` reads
      # both columns. Arguments are compared as written, so `order(:rank)`
      # followed by `order('rank')` is left alone -- Active Record treats a
      # symbol and a string as separate terms and emits both.
      #
      # Only calls whose arguments are all literals are registered, so removing
      # one cannot discard a method call that does other work.
      #
      # `limit`, `offset` and `reorder` are deliberately not checked. Repeating
      # those is also wasteful, but the last call replaces the earlier ones
      # rather than merging with them, so the offense and its correction are a
      # different shape.
      #
      # @safety
      #   This cop is unsafe because it cannot know that the receiver is an
      #   Active Record relation. A different object may define a method of the
      #   same name for which repetition is meaningful.
      #
      # @example
      #   # bad
      #   Post.eager_load(:user).eager_load(:user)
      #   Post.order(:rank).order(:rank)
      #   Post.where(published: true).joins(:user).joins(:user)
      #
      #   # good
      #   Post.eager_load(:user)
      #   Post.order(:rank)
      #   Post.where(published: true).joins(:user)
      #
      #   # good - different arguments combine rather than repeat
      #   Post.order(:rank).order(:title)
      #   Post.select(:id).select(:title)
      #
      #   # good - `distinct(false)` undoes `distinct`
      #   Post.distinct.distinct(false)
      class RedundantQueryMethods < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Redundant `%<method>s` detected.'

        QUERY_METHODS = %i[
          distinct
          eager_load
          group
          includes
          joins
          left_joins
          left_outer_joins
          order
          preload
          select
        ].freeze

        RESTRICT_ON_SEND = QUERY_METHODS

        LITERAL_TYPES = %i[const false float int nil str sym true].freeze

        def on_send(node)
          return unless node.receiver && node.loc.dot
          return if node.block_node
          return unless literal_arguments?(node)
          return unless repeat_of_earlier_call?(node)

          range = offense_range(node)
          add_offense(range, message: format(MSG, method: node.method_name)) do |corrector|
            corrector.remove(removal_range(range))
          end
        end

        private

        # Whether an earlier call in the same chain is the same method with the
        # same arguments. Intervening calls do not matter: the values are merged
        # into a set whenever the two calls happen, so
        # `order(:rank).where(...).order(:rank)` is as redundant as the adjacent
        # form.
        def repeat_of_earlier_call?(node)
          each_earlier_call(node) do |earlier|
            return true if earlier.method?(node.method_name) && earlier.arguments == node.arguments
          end
          false
        end

        # Every call preceding `node` in its chain, innermost last. A call
        # taking a block is stepped over rather than compared, since its body
        # is part of what it means and arguments alone cannot say two are equal.
        def each_earlier_call(node)
          current = node.receiver

          while current
            case current.type
            when :send, :csend
              yield current
              current = current.receiver
            when :block, :numblock, :itblock
              current = current.receiver
            else
              break
            end
          end
        end

        # Only literals, so that removing the repeated call cannot remove a
        # method call that does work of its own -- `joins(next_association!)`
        # twice is not something this cop should touch.
        def literal_arguments?(node)
          node.arguments.all? { |argument| literal?(argument) }
        end

        def literal?(node)
          return true if LITERAL_TYPES.include?(node.type)
          return node.children.all? { |child| literal?(child) } if node.pair_type?
          return node.each_child_node.all? { |child| literal?(child) } if node.type?(:array, :hash)

          false
        end

        # The call with the dot that leads to it, so the offense points at what
        # would be deleted rather than at the whole chain.
        def offense_range(node)
          range_between(node.loc.dot.begin_pos, node.source_range.end_pos)
        end

        # Preceding whitespace goes too, which keeps a multiline chain from
        # being left with a blank line where the call used to be. This is wider
        # than the highlighted range, which stays on the call itself.
        def removal_range(range)
          range_with_surrounding_space(range, side: :left, newlines: true)
        end
      end
    end
  end
end
