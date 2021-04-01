# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Rails 6.0 has added `delete_by` as a relation method.
      #
      # This cop identifies places where `find_by(...)&.delete` and `where(...).delete_all`
      # can be replaced by `delete_by`.
      #
      # @example
      #   # bad
      #   unreads.find_by(readable: readable)&.delete
      #   unreads.where(readable: readable).delete_all
      #
      #   # good
      #   unreads.delete_by(readable: readable)
      #
      class DeleteBy < Base
        include DeleteByAndDestroyByMethods
        extend AutoCorrector
        extend TargetRailsVersion

        minimum_target_rails_version 6.0

        RESTRICT_ON_SEND = %i[delete delete_all].freeze

        def on_send(node)
          return unless (receiver = node.receiver)&.send_type?
          return unless node.method?(:delete) && receiver.method?(:find_by) ||
                        node.method?(:delete_all) && receiver.method?(:where)

          register_offense(node, receiver)
        end

        alias on_csend on_send

        private

        def preferred_method
          'delete_by'
        end
      end
    end
  end
end
