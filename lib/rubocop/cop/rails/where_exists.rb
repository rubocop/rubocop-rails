# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop enforces the use of `exists?(...)` over `where(...).exists?`.
      #
      # @example
      #   # bad
      #   User.where(name: 'john').exists?
      #   User.where(['name = ?', 'john']).exists?
      #   User.where('name = ?', 'john').exists?
      #   user.posts.where(published: true).exists?
      #
      #   # good
      #   User.exists?(name: 'john')
      #   User.where('length(name) > 10').exists?
      #   user.posts.exists?(published: true)
      #
      class WhereExists < Cop
        MSG = 'Prefer `%<good_method>s` over `%<bad_method>s`.'

        def_node_matcher :where_exists_call?, <<~PATTERN
          (send (send _ :where $...) :exists?)
        PATTERN

        def on_send(node)
          where_exists_call?(node) do |args|
            return unless convertable_args?(args)

            range = correction_range(node)
            message = format(MSG, good_method: build_good_method(args), bad_method: range.source)
            add_offense(node, location: range, message: message)
          end
        end

        def autocorrect(node)
          args = where_exists_call?(node)

          lambda do |corrector|
            corrector.replace(
              correction_range(node),
              build_good_method(args)
            )
          end
        end

        private

        def convertable_args?(args)
          args.size > 1 || args[0].hash_type? || args[0].array_type?
        end

        def correction_range(node)
          node.receiver.loc.selector.join(node.loc.selector)
        end

        def build_good_method(args)
          if args.size > 1
            "exists?([#{args.map(&:source).join(', ')}])"
          else
            "exists?(#{args[0].source})"
          end
        end
      end
    end
  end
end
