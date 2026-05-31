# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks that every `create_table` and every column inside it carries a `comment:` option,
      # so the database is self-documenting via `COMMENT ON TABLE` / `COMMENT ON COLUMN`.
      #
      # Index definitions, timestamps, foreign keys, and check constraints are skipped.
      # Tables listed under `ExcludedTables` are ignored entirely.
      # Column names listed under `ExcludedColumns` are ignored within every table.
      #
      # @example
      #   # bad
      #   create_table 'users', force: :cascade do |t|
      #     t.string 'email', null: false
      #   end
      #
      #   # good
      #   create_table 'users', force: :cascade, comment: 'Application users' do |t|
      #     t.string 'email', null: false, comment: 'Login identifier'
      #   end
      class SchemaCommentPresence < Base
        MSG_TABLE  = 'Missing `comment:` on table `%<name>s`.'
        MSG_COLUMN = 'Missing `comment:` on column `%<table>s.%<name>s`.'

        COLUMN_METHODS = %i[
          bigint binary boolean citext cidr column date datetime decimal float hstore inet
          integer interval json jsonb macaddr numeric primary_key references belongs_to
          string text time timestamp uuid virtual vector
        ].to_set.freeze

        def_node_matcher :create_table_name, <<~PATTERN
          (send nil? :create_table $_name ...)
        PATTERN

        def on_block(node)
          send_node = node.send_node
          return unless send_node.method?(:create_table)

          name_node = create_table_name(send_node)
          table_name = literal_value(name_node)
          return unless table_name
          return if excluded_table?(table_name)

          check_table(send_node, table_name)
          check_columns(node.body, table_name) if node.body
        end
        alias on_numblock on_block
        alias on_itblock on_block

        private

        def check_table(send_node, table_name)
          return if commented?(send_node)

          add_offense(send_node, message: format(MSG_TABLE, name: table_name))
        end

        def check_columns(body, table_name)
          column_sends(body).each do |send_node|
            column_name = literal_value(send_node.first_argument)
            next unless column_name
            next if excluded_column?(column_name)
            next if commented?(send_node)

            add_offense(send_node, message: format(MSG_COLUMN, table: table_name, name: column_name))
          end
        end

        def column_sends(body)
          statements_of(body).select { |stmt| column_send?(stmt) }
        end

        def statements_of(body)
          body.begin_type? ? body.children : [body]
        end

        def column_send?(node)
          return false unless node.respond_to?(:send_type?) && node.send_type?
          return false unless node.receiver&.lvar_type?
          return false unless COLUMN_METHODS.include?(node.method_name)

          literal_name?(node.first_argument)
        end

        def literal_name?(node)
          node&.type?(:str, :sym)
        end

        def commented?(send_node)
          last = send_node.last_argument
          return false unless last&.hash_type?

          last.each_pair.any? { |pair| pair.key.sym_type? && pair.key.value == :comment }
        end

        def literal_value(node)
          return unless node&.type?(:str, :sym)

          node.value.to_s
        end

        def excluded_table?(name)
          list('ExcludedTables').include?(name)
        end

        def excluded_column?(name)
          list('ExcludedColumns').include?(name)
        end

        def list(key)
          Array(cop_config[key]).map(&:to_s)
        end
      end
    end
  end
end
