# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Looks for `delegate` in private section without `private: true` option.
      #
      # @example
      #   # bad
      #   private
      #   delegate :baz, to: :bar
      #
      #   # bad
      #   delegate :baz, to: :bar, private: true
      #
      #   # good
      #   private
      #   delegate :baz, to: :bar, private: true
      class DelegatePrivate < Base
        extend TargetRailsVersion

        MSG_MISSING_PRIVATE = '`delegate` in private section should have `private: true` option'
        MSG_WRONG_PRIVATE = 'private `delegate` should be put in private section'

        minimum_target_rails_version 6.0

        def on_send(node)
          mark_scope(node)
          return unless delegate_node?(node)

          if private_scope?(node) && !private_delegate?(node)
            add_offense(node, message: MSG_MISSING_PRIVATE)
          elsif public_scope?(node) && private_delegate?(node)
            add_offense(node, message: MSG_WRONG_PRIVATE)
          end
        end

        def on_class(node)
          cut_from_private_range(node.location.first_line..node.location.last_line)
        end

        private

        def private_delegate?(node)
          node.arguments.select(&:hash_type?).each do |hash_node|
            hash_node.each_pair do |key_node, value_node|
              return true if key_node.value == :private && value_node.true_type?
            end
          end

          false
        end

        def mark_scope(node)
          return if node.receiver || !node.arguments.empty?

          @private_ranges ||= []

          scope_range = node.parent.location.first_line..node.parent.location.last_line
          if node.method?(:private)
            add_to_private_range(scope_range)
          elsif node.method?(:public)
            cut_from_private_range(scope_range)
          end
        end

        def delegate_node?(node)
          return false if node.receiver

          node.method?(:delegate)
        end

        def private_scope?(node)
          @private_ranges&.any? { |range| range.include?(node.location.first_line) }
        end

        def public_scope?(node)
          !private_scope?(node)
        end

        def add_to_private_range(scope_range)
          @private_ranges ||= []
          @private_ranges += [scope_range]
        end

        def cut_from_private_range(scope_range)
          @private_ranges ||= []

          @private_ranges = @private_ranges.each.with_object([]) do |private_range, new_ranges|
            next if scope_range.cover?(private_range)

            if private_range.cover?(scope_range)
              new_ranges << (private_range.begin...scope_range.begin)
              new_ranges << ((scope_range.end + 1)..private_range.end)
            else
              new_ranges << private_range
            end
          end
        end
      end
    end
  end
end
