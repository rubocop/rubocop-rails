# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Rails 6.0 has added `delete_by` as a relation method.
      #
      # This cop identifies places where `find_by(...)&.destroy` and `where(...).destroy_all`
      # can be replaced by `destroy_by`.
      #
      # @example
      #   # bad
      #   unreads.find_by(readable: readable)&.destroy
      #   unreads.where(readable: readable).destroy_all
      #
      #   # good
      #   unreads.destroy_by(readable: readable)
      #
      class DestroyBy < Base
        include DeleteByAndDestroyByMethods
        extend AutoCorrector
        extend TargetRailsVersion

        minimum_target_rails_version 6.0

        def on_send(node)
          return unless (receiver = node.receiver)&.send_type?
          return unless node.method?(:destroy) && receiver.method?(:find_by) ||
                        node.method?(:destroy_all) && receiver.method?(:where)

          register_offense(node, receiver)
        end

        alias on_csend on_send

        private

        def preferred_method
          'destroy_by'
        end
      end
    end
  end
end
