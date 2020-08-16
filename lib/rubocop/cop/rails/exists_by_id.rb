# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop enforces the use of `exists?(id)` over `exists?(id: id)`.
      #
      # @example
      #   # bad
      #   User.exists?(id: 1)
      #   User.exists?(id: '1')
      #
      #   # good
      #   User.exists?(1)
      #   User.exists?('1')
      #   User.exists?(id: [1, 2, 3])
      #   User.exists?(id: 1, email: 'test@example.com')
      #
      class ExistsById < Cop
        include RangeHelp

        MSG = 'Prefer `%<good_method>s` over `%<bad_method>s`.'

        def_node_matcher :exists_by_id?, <<~PATTERN
          (send _ :exists? (hash (pair (sym :id) $_)))
        PATTERN

        def on_send(node)
          exists_by_id?(node) do |id_value|
            return if id_value.array_type?

            good_method = build_good_method(id_value)
            bad_method = build_bad_method(id_value)
            message = format(MSG, good_method: good_method, bad_method: bad_method)
            range = offense_range(node)
            add_offense(node, location: range, message: message)
          end
        end

        def autocorrect(node)
          id_value = exists_by_id?(node)
          range = offense_range(node)
          lambda do |corrector|
            replacement = build_good_method(id_value)
            corrector.replace(range, replacement)
          end
        end

        private

        def offense_range(node)
          range_between(node.loc.selector.begin_pos, node.loc.expression.end_pos)
        end

        def build_good_method(id_value)
          "exists?(#{id_value.source})"
        end

        def build_bad_method(id_value)
          "exists?(id: #{id_value.source})"
        end
      end
    end
  end
end
