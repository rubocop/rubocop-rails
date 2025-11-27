# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for manual construction of ordering logic and suggests using `in_order_of` instead.
      #
      # `in_order_of` was introduced in Rails 7.0 to allow custom ordering of records
      # without using raw SQL with `CASE` statements or `Arel.sql`.
      #
      # @example
      #   # bad
      #   Post.order(
      #     Arel.sql(
      #       <<~SQL
      #         case status
      #         when 'draft' then 1
      #         when 'published' then 2
      #         when 'archived' then 3
      #         else 4 end
      #       SQL
      #     )
      #   )
      #
      #   # good
      #   Post.in_order_of(:status, %w[draft published archived])
      #
      #   # bad - using MySQL FIELD function
      #   Post.order(
      #     Arel.sql("FIELD(status, 'draft', 'published', 'archived')")
      #   )
      #
      #   # good
      #   Post.in_order_of(:status, %w[draft published archived])
      #
      #   # bad - with string interpolation
      #   Post.order(Arel.sql("FIELD(status, '#{statuses.join("', '")}')"))
      #
      #   # good
      #   Post.in_order_of(:status, statuses)
      #
      class InOrderOf < Base
        extend TargetRailsVersion

        minimum_target_rails_version 7.0

        MSG = 'Use `in_order_of` for ordering instead of manually constructing SQL.'
        RESTRICT_ON_SEND = %i[order].freeze

        # Matches: case column when ... or case #{var} when ...
        CASE_WHEN_PATTERN = /\bcase\s+(\w+|#\{[^}]+\})\s+when\b/im.freeze
        # Matches: FIELD(column, ...)
        FIELD_FUNCTION_PATTERN = /\bFIELD\s*\(/i.freeze

        AREL_CONST_NAME = 'Arel'
        HEREDOC_START = '<<'

        def on_send(node)
          return unless node.method?(:order)
          return unless (sql_string = extract_sql_string(node))
          return unless custom_order_sql?(sql_string)

          add_offense(node.loc.selector)
        end

        private

        def extract_sql_string(node)
          sql_arg = sql_argument(node)
          extract_string_content(sql_arg) if sql_arg
        end

        def sql_argument(node)
          arg = node.first_argument
          return unless arg&.send_type? && arg.method?(:sql)
          return unless arel_const?(arg.receiver)

          arg.first_argument if arg.first_argument&.type?(:str, :dstr)
        end

        def extract_string_content(sql_arg)
          case sql_arg.type
          when :str then sql_arg.str_content
          when :dstr then extract_dstr_content(sql_arg)
          end
        end

        def extract_dstr_content(sql_arg)
          source = sql_arg.source
          source.start_with?(HEREDOC_START) ? heredoc_content(sql_arg) : source[1...-1]
        end

        def heredoc_content(sql_arg)
          sql_arg.each_child_node(:str).map(&:str_content).join
        end

        def arel_const?(node)
          node&.const_type? && node.const_name == AREL_CONST_NAME
        end

        def custom_order_sql?(sql_string)
          sql_string.match?(CASE_WHEN_PATTERN) || sql_string.match?(FIELD_FUNCTION_PATTERN)
        end
      end
    end
  end
end
