# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop identifies places where `pluck` is used in `where` query methods
      # and can be replaced with `select`.
      #
      # Since `pluck` is an eager method and hits the database immediately,
      # using `select` helps to avoid additional database queries.
      #
      # @example
      #   # bad
      #   Post.where(user_id: User.active.pluck(:id))
      #
      #   # good
      #   Post.where(user_id: User.active.select(:id))
      #
      class PluckInWhere < Cop
        include ActiveRecordHelper

        MSG = 'Use `select` instead of `pluck` within `where` query method.'

        def on_send(node)
          add_offense(node, location: :selector) if node.method?(:pluck) && in_where?(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector, 'select')
          end
        end
      end
    end
  end
end
