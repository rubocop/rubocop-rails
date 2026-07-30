# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces date/time columns naming conventions.
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
      class DateAndTimeColumnName < Base
        prepend MigrationsHelper

        MSG = 'Name `%<type>s` columns with `%<suffix>s` suffixes.'
        TYPE_TO_SUFFIX = { datetime: '_at', timestamp: '_at', date: '_on', time: '_time' }.freeze

        def on_send(node)
          return unless in_migration?(node)

          column_name, type = column_name_and_type(node)
          return unless column_name

          suffix = TYPE_TO_SUFFIX[type]
          return if !suffix || column_name.value.to_s.end_with?(suffix)

          message = format(MSG, type: type, suffix: suffix)
          add_offense(column_name, message: message)
        end

        private

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
