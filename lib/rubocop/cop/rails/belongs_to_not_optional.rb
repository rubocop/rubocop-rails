require 'pry'

module RuboCop
  module Cop
    module Rails
      # It's possible for the belongs_to: in an active model
      # to say it's optional, when the database says it's
      # required.
      #
      # @example
      #   # bad - if the ____ has a `NOT NULL` constraint
      #   belongs_to :company, optional: true
      #
      #   # good - if the schema has a NULL column
      #   belongs_to :company, optional: true
      #
      class BelongsToNotOptional < Base
        include ActiveRecordHelper

        MSG = "Relationship is required. Either remove 'optional: true' or add a NOT NULL constraint to column."

        def on_send(node)
          return unless schema

          belongs_to_optional, column_not_null_case = find_information(node)
          # binding.pry

          if belongs_to_optional && column_not_null_case
            add_offense(node)
          end
        end

        def find_information(node)
          klass = class_node(node)
          return unless klass

          belongs_to_optional = find_belongs_to(klass).to_a.last&.last_argument.values.last.to_s == "(true)"

          table = schema.table_by(name: table_name(klass))
          return [false, false] unless table

          column_name = belongs_to(klass)
          # column = schema.table_by(name: table_name).columns.find { |c| c.name == column_name }
          column = table.columns.find { |c| c.name == column_name }
          column_not_null_case = column.not_null
          [belongs_to_optional, column_not_null_case]
        end

        def class_node(node)
          node.each_ancestor.find(&:class_type?)
        end

        def belongs_to(class_node)
          belongs_to = find_belongs_to(class_node).to_a.last&.first_argument
          return belongs_to.value.to_s if belongs_to

          # help! see active_record_helper#table_name for ideas
        end
      end
    end
  end
end
