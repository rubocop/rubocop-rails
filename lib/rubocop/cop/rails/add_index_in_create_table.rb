# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Detects when `add_index` is called after `create_table` in a migration
      # and suggests adding the indexes inside the `create_table` block instead.
      #
      # Adding indexes inside `create_table` using `t.index` is cleaner and
      # ensures the table and indexes are created together.
      #
      # @example
      #   # bad
      #   def change
      #     create_table :users do |t|
      #       t.string :email
      #       t.timestamps
      #     end
      #
      #     add_index :users, :email
      #   end
      #
      #   # good
      #   def change
      #     create_table :users do |t|
      #       t.string :email
      #       t.timestamps
      #
      #       t.index :email
      #     end
      #   end
      #
      #   # bad
      #   def change
      #     create_table :posts do |t|
      #       t.string :title
      #       t.references :user
      #     end
      #
      #     add_index :posts, :title, unique: true, algorithm: :concurrently
      #   end
      #
      #   # good
      #   def change
      #     create_table :posts do |t|
      #       t.string :title
      #       t.references :user
      #
      #       t.index :title, unique: true
      #     end
      #   end
      #
      class AddIndexInCreateTable < Base
        include ActiveRecordMigrationsHelper

        MSG = 'Add indexes using `t.index` inside `create_table` block instead of `add_index` after table creation.'

        RESTRICT_ON_SEND = %i[add_index].freeze

        # @!method add_index_table_name(node)
        def_node_matcher :add_index_table_name, <<~PATTERN
          (send nil? :add_index (sym $_table_name) ...)
        PATTERN

        # @!method create_table_table_name(node)
        def_node_matcher :create_table_table_name, <<~PATTERN
          (any_block
            (send nil? :create_table (sym $_table_name) ...)
            ...
          )
        PATTERN

        def on_send(node)
          return unless node.method?(:add_index)

          table_name = add_index_table_name(node)
          return unless table_name

          # Find sibling create_table calls for the same table
          parent_begin = find_parent_begin_or_def(node)
          return unless parent_begin

          create_table_nodes = find_create_table_for(parent_begin, table_name)
          return if create_table_nodes.empty?

          # Check if the create_table appears before this add_index
          create_table_node = create_table_nodes.find do |ct_node|
            ct_node.source_range.end_pos < node.source_range.begin_pos
          end

          return unless create_table_node

          add_offense(node)
        end

        private

        def find_parent_begin_or_def(node)
          current = node.parent
          while current
            return current if current.type?(:begin, :def, :block)

            current = current.parent
          end
          nil
        end

        def find_create_table_for(parent_node, table_name)
          results = []

          parent_node.each_descendant(:block, :numblock) do |block_node|
            next unless block_node.method?(:create_table)

            matched_table = create_table_table_name(block_node)
            results << block_node if matched_table == table_name
          end

          results
        end
      end
    end
  end
end
