# frozen_string_literal: true

module RuboCop
  module Rails
    module SchemaLoader
      # Represent db/schema.rb
      class Schema
        attr_reader :tables

        def initialize(ast)
          @tables = []
          build!(ast)
        end

        def table_by(name:)
          tables.find do |table|
            table.name == name
          end
        end

        private

        def build!(ast)
          raise "Unexpected type: #{ast.type}" unless ast.block_type?

          each_table(ast) do |table_def|
            @tables << Table.new(table_def)
          end
        end

        def each_table(ast)
          case ast.body.type
          when :begin
            ast.body.children.each do |node|
              next unless node.block_type? && node.method?(:create_table)

              yield(node)
            end
          else
            yield ast.body
          end
        end
      end

      # Reprecent a table
      class Table
        attr_reader :name, :columns, :indices

        def initialize(node)
          @name = node.send_node.first_argument.value
          @columns = build_columns(node)
          @indices = build_indices(node)
        end

        def with_column?(name:)
          @columns.any? { |c| c.name == name }
        end

        private

        def build_columns(node)
          each_content(node).map do |child|
            next unless child.send_type?
            next if child.method?(:index)

            Column.new(child)
          end.compact
        end

        def build_indices(node)
          each_content(node).map do |child|
            next unless child.send_type?
            next unless child.method?(:index)

            Index.new(child)
          end.compact
        end

        def each_content(node)
          return enum_for(__method__, node) unless block_given?

          case node.body.type
          when :begin
            node.body.children.each do |child|
              yield(child)
            end
          else
            yield(node.body)
          end
        end
      end

      # Reprecent a column
      class Column
        attr_reader :name, :type, :not_null

        def initialize(node)
          @name = node.first_argument.value
          @type = node.method_name
          @not_null = nil

          analyze_keywords!(node)
        end

        private

        def analyze_keywords!(node)
          pairs = node.arguments.last
          return unless pairs.hash_type?

          pairs.each_pair do |k, v|
            if k.value == :null
              @not_null = v.true_type? ? false : true
            end
          end
        end
      end

      # Reprecent an index
      class Index
        attr_reader :name, :columns, :expression, :unique

        def initialize(node)
          node.first_argument
          @columns, @expression = build_columns_or_expr(node)
          @unique = nil

          analyze_keywords!(node)
        end

        private

        def build_columns_or_expr(node)
          arg = node.first_argument
          if arg.array_type?
            [arg.values.map(&:value), nil]
          else
            [[], arg.value]
          end
        end

        def analyze_keywords!(node)
          pairs = node.arguments.last
          return unless pairs.hash_type?

          pairs.each_pair do |k, v|
            case k.value
            when :name
              @name = v.value
            when :unique
              @unique = true
            end
          end
        end
      end
    end
  end
end
