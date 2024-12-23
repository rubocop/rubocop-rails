# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop enforces date/time columns naming conventions.
      # Specifically, `date` column should end with `_on` suffix,
      # `datetime` and `timestamp` - with `_at` suffix,
      # `time` - with `_time` suffix.
      #
      # @example
      #   # bad
      #   add_column :orders, :created_on, :datetime
      #   t.column :visited_at, :date
      #   t.time :start_at
      #
      #   # good
      #   add_column :orders, :created_at, :datetime
      #   t.column :visited_on, :date
      #   t.time :start_time
      #
      # @example StartAfterMigrationVersion: 20211007000001
      #   # bad
      #   # db/migrate/20211007000002_add_created_on_to_orders.rb
      #   add_column :orders, :created_on, :datetime
      #
      #   # good
      #   # db/migrate/20211007000001_add_created_on_to_orders.rb
      #   add_column :orders, :created_on, :datetime
      #
      class DateAndTimeColumnName < Base
        include StartAfterMigrationVersion

        MSG = 'Name `%<type>s` columns with `%<suffix>s` suffixes.'
        TYPE_TO_SUFFIX = {
          datetime: '_at',
          timestamp: '_at',
          date: '_on',
          time: '_time'
        }.freeze

        def on_send(node)
          return unless in_migration?(node) && starts_after_migration_version?

          column_name, type = column_name_and_type(node)
          return unless column_name

          suffix = TYPE_TO_SUFFIX[type]
          return if !suffix || column_name.value.to_s.end_with?(suffix)

          message = format(MSG, type: type, suffix: suffix)
          add_offense(column_name, message: message)
        end

        private

        def_node_matcher :migration_base?, <<~PATTERN
          {
            (send (const (const nil? :ActiveRecord) :Migration) :[] _)
            (const (const nil? :ActiveRecord) :Migration)
          }
        PATTERN

        def in_migration?(node)
          class_node = node.each_ancestor(:class).first
          migration_base?(class_node&.parent_class)
        end

        def column_name_and_type(node)
          case node.method_name
          when :add_column
            _table_name, column_name, type, = *node.arguments
            type = type.value
          when :column
            column_name, type, = *node.arguments
            type = type.value
          when *TYPE_TO_SUFFIX.keys
            column_name = node.first_argument
            type = node.method_name
          end

          [column_name, type]
        end
      end
    end
  end
end
