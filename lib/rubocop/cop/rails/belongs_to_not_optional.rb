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
        extend AutoCorrector

        MSG = "Relationship is required. Either remove 'optional: true' or add a NOT NULL constraint to column."

        def on_send(node)
          return unless schema
          return unless node.source.include?('belongs_to')
          return unless node.source.include?('optional')

          belongs_to_optional, column_not_null_case = find_information(node)

          if belongs_to_optional && column_not_null_case
            add_offense(node) do |corrector|
              corrector.replace(node, node.source.sub(', optional: true', ''))
            end
          end
        end

        def find_information(node)
          # Note that this only works if `optional: true` is at the end of the line
          belongs_to_says_it_is_optional = find_belongs_to(node).to_a&.last&.last_argument&.values&.last.to_s == "(true)"
          return unless belongs_to_says_it_is_optional

          klass = class_node(node)
          return unless klass

          table = schema.table_by(name: table_name(klass))
          return unless table

          column_name = belongs_to(node) + "_id"
          # column = schema.table_by(name: table_name).columns.find { |c| c.name == column_name }
          column = table.columns.find { |c| c.name == column_name }
          return unless column

          column_not_null_case = column.not_null
          [belongs_to_says_it_is_optional, column_not_null_case]
        end

        def class_node(node)
          node.each_ancestor.find(&:class_type?)
        end

        def belongs_to(node)
          belongs_to = find_belongs_to(node).to_a.last&.first_argument
          return belongs_to.value.to_s if belongs_to

          # help! see active_record_helper#table_name for ideas
        end
      end
    end
  end
end
