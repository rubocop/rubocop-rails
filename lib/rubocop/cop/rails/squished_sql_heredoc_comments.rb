# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for single-line comments (`--`) in SQL heredocs that use `.squish`.
      #
      # `.squish` joins the heredoc into a single line, so everything after a `--`
      # comment becomes part of that comment. The query still runs, but without
      # the conditions that follow the comment, which can turn a narrow `DELETE`
      # or `UPDATE` into one that touches every row.
      #
      # A `--` comment on the last line of the query is allowed, because there is
      # nothing after it to swallow.
      #
      # @example
      #   # bad
      #   execute(<<~SQL.squish)
      #     DELETE FROM records
      #     WHERE expired = true -- only expired records
      #     AND user_id = 1
      #   SQL
      #
      #   # good
      #   execute(<<~SQL.squish)
      #     DELETE FROM records
      #     WHERE expired = true /* only expired records */
      #     AND user_id = 1
      #   SQL
      #
      #   # good
      #   execute(<<~SQL)
      #     DELETE FROM records
      #     WHERE expired = true -- only expired records
      #     AND user_id = 1
      #   SQL
      #
      class SquishedSQLHeredocComments < Base
        include Heredoc

        MSG = 'Use `/* */` instead of `--` in a squished SQL heredoc. ' \
              '`.squish` joins the lines, so `--` comments out the rest of the query.'
        SQL = 'SQL'
        SQL_IDENTIFIER_MARKERS = /(".+?")|('.+?')|(\[.+?\])/.freeze
        SINGLE_LINE_COMMENT = '--'

        def on_heredoc(node)
          return unless sql_heredoc?(node) && squished?(node)
          return unless comment_followed_by_sql?(node)

          add_offense(node)
        end

        private

        def sql_heredoc?(node)
          delimiter_string(node) == SQL
        end

        def squished?(node)
          node.parent&.send_type? && node.parent.method?(:squish)
        end

        def comment_followed_by_sql?(node)
          lines = node.loc.heredoc_body.source.lines.map { |line| line.gsub(SQL_IDENTIFIER_MARKERS, '') }

          first_comment = lines.index { |line| line.include?(SINGLE_LINE_COMMENT) }
          return false unless first_comment

          lines.drop(first_comment + 1).any? { |line| !line.strip.empty? }
        end
      end
    end
  end
end
