# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks that a in_batches block is not part of an implicit ddl transaction in a migration.
      #
      # @example
      #
      #  # good
      #  class SomeMigration < ActiveRecord::Migration[8.0]
      #   disable_ddl_transaction!
      #   def up
      #    Model.in_batches do |relation|
      #     # Optionally, you can consider wrapping the
      #     Model.transaction do
      #      # Your batch processing logic here
      #     end
      #    end
      #   end
      #  end
      #
      #  # bad
      #  class SomeMigration < ActiveRecord::Migration[8.0]
      #   def up
      #    Model.in_batches do |relation|
      #      # Your batch processing logic here
      #    end
      #   end
      #  end
      class InBatchesMigrationTransaction < Base
        include MigrationsHelper

        MSG = 'Do not use `in_batches` without `disable_ddl_transaction!` in migrations.'

        RESTRICT_ON_SEND = %i[in_batches].freeze

        def on_send(node)
          return unless in_migration?(node)
          return if disable_ddl_transaction?(node)

          add_offense(node)
        end

        private

        def disable_ddl_transaction?(node)
          node.each_ancestor(:class).any? do |class_node|
            class_node.body.each_child_node(:send).any? do |send_node|
              send_node.method?(:disable_ddl_transaction!)
            end
          end
        end
      end
    end
  end
end
