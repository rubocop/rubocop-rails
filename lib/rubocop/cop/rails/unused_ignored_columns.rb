# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Suggests you remove a column that does not exist in the schema from `ignored_columns`.
      # `ignored_columns` is necessary to drop a column from RDBMS, but you don't need it after the migration
      # to drop the column. You avoid forgetting to remove `ignored_columns` by this cop.
      #
      # @example
      #   # bad
      #   class User < ApplicationRecord
      #     self.ignored_columns = [:already_removed_column]
      #   end
      #
      #   # good
      #   class User < ApplicationRecord
      #     self.ignored_columns = [:still_existing_column]
      #   end
      #
      class UnusedIgnoredColumns < Base
        include ActiveRecordHelper

        MSG = 'Remove `%<column_name>s` from `ignored_columns` because the column does not ' \
              'exist in schema `%<schema_path>s`.'
        RESTRICT_ON_SEND = %i[ignored_columns=].freeze

        def_node_matcher :ignored_columns, <<~PATTERN
          (send self :ignored_columns= $array)
        PATTERN

        def_node_matcher :appended_ignored_columns, <<~PATTERN
          (op-asgn (send self :ignored_columns) :+ $array)
        PATTERN

        def_node_matcher :column_name, <<~PATTERN
          ({str sym} $_)
        PATTERN

        def on_send(node)
          return unless (columns = ignored_columns(node) || appended_ignored_columns(node))
          return unless schema

          table = table(node)
          return unless table

          columns.children.each do |column_node|
            check_column_existence(column_node, table)
          end
        end
        alias on_op_asgn on_send

        private

        def check_column_existence(column_node, table)
          column_name = column_name(column_node)
          return unless column_name
          return if table.with_column?(name: column_name.to_s)

          message = format(MSG, column_name: column_name, schema_path: configured_schema_path)
          add_offense(column_node, message: message)
        end

        def class_node(node)
          node.each_ancestor.find(&:class_type?)
        end

        def table(node)
          klass = class_node(node)
          return unless klass

          schema.table_by(name: table_name(klass))
        end

        def configured_schema_path
          @configured_schema_path ||= cop_config['SchemaPath'] || 'db/schema.rb'
        end

        def schema
          RuboCop::Rails::SchemaLoader.load(target_ruby_version, configured_schema_path)
        end
      end
    end
  end
end
