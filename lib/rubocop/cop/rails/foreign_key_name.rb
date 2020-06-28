# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop enforces that foreign keys are created with explicitly specified names.
      #
      # @example
      #   # bad
      #   add_foreign_key :articles, :authors
      #   t.foreign_key :authors
      #
      #   # good
      #   add_foreign_key :articles, :authors, name: :articles_authors_fk
      #   t.foreign_key :authors, name: :articles_authors_fk
      #
      # @example StartAfterMigrationVersion: 20211007000001
      #   # bad
      #   # db/migrate/20211007000002_create_articles.rb
      #   add_foreign_key :articles, :authors
      #
      #   # good
      #   # db/migrate/20211007000001_create_articles.rb
      #   add_foreign_key :articles, :authors
      #
      class ForeignKeyName < Base
        extend AutoCorrector
        include StartAfterMigrationVersion

        MSG = 'Name your foreign keys explicitly instead of relying on Rails auto-generated FK names.'

        RESTRICT_ON_SEND = %i[add_foreign_key foreign_key].freeze
        TABLE_METHODS = %i[create_table change_table].freeze

        def_node_matcher :table_operation?, <<~PATTERN
          (block (send _ {:create_table :change_table} ...) ...)
        PATTERN

        def_node_matcher :adding_foreign_key?, <<~PATTERN
          {
            (send nil? :add_foreign_key _ $_ $!(hash <(pair (sym :name) _) ...>) ?)
            (send !nil? :foreign_key $_ $!(hash <(pair (sym :name) _) ...>) ?)
          }
        PATTERN

        def on_send(node)
          return unless starts_after_migration_version?

          adding_foreign_key?(node) do |to_table_node, options_node|
            return if node.method?(:foreign_key) && !within_table_method?(node)

            options_node = options_node.first

            add_offense(node) do |corrector|
              foreign_key_name = foreign_key_name(node, to_table_node, options_node)

              if options_node
                corrector.insert_after(options_node, ", name: :#{foreign_key_name}")
              else
                corrector.insert_after(node, ", name: :#{foreign_key_name}")
              end
            end
          end
        end

        private

        def within_table_method?(node)
          parent = node.each_ancestor(:block).first
          !parent.nil? && table_operation?(parent)
        end

        def foreign_key_name(node, to_table_node, options_node)
          column = "#{to_table_node.value.to_s.singularize}_id"

          if options_node
            column_pair = options_node.pairs.find { |p| p.key.value.to_sym == :column }
            column = column_pair.value.value if column_pair
          end

          from_table = from_table(node)
          "#{from_table}_#{column}_fk"
        end

        def from_table(node)
          case node.method_name
          when :add_foreign_key
            node.arguments[0].value
          else
            table_node = node.ancestors.find { |n| n.block_type? && TABLE_METHODS.include?(n.method_name) }
            table_node.send_node.arguments[0].value
          end
        end
      end
    end
  end
end
