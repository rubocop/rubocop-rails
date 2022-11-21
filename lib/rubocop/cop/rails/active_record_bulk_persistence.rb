# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for iterative save/create/update methods instead of using insert_all/upsert_all
      #
      # @safety
      #   insert_all/upsert_all do not instantiate any models nor do they trigger Active Record
      #   callbacks or validations.
      #
      # @example
      #   # bad
      #   events.each do |event|
      #     event.save!
      #   end
      #
      #   # good
      #   Event.insert_all(events)
      #
      class ActiveRecordBulkPersistence < Base
        include ActiveRecordHelper

        MSG = 'For bulk operations, use `insert_all` or `upsert_all` instead of repeated calls to `%<method>s`.'

        ITERATIVE_METHODS = %i[
          each find_each each_with_index each_with_object reduce inject
          map collect flat_map filter_map
        ].freeze
        RESTRICT_ON_SEND = %i[
          save update update_attributes destroy create
          save! update! update_attribute destroy! create!
        ].freeze

        def on_send(node)
          return unless iteration_parent?(node)

          range = node.loc.selector
          add_offense(range, message: format(MSG, method: node.method_name))
        end

        private

        def iteration_parent?(node)
          parent = node.parent
          return false if parent.nil?
          return true if iteration?(parent)

          iteration_parent?(parent)
        end

        def iteration?(node)
          node.block_type? && ITERATIVE_METHODS.include?(node.method_name)
        end
      end
    end
  end
end
