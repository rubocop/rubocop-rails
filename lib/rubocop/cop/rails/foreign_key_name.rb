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
      class ForeignKeyName < Cop
        MSG = 'Name your foreign keys explicitly instead of relying on Rails auto-generated FK names.'

        def_node_matcher :foreign_key_name_candidate?, <<~PATTERN
          {
            (send nil? :add_foreign_key _ _ $hash_type? ?)
            (send !nil? :foreign_key _ $hash_type? ?)
          }
        PATTERN

        def on_send(node)
          foreign_key_name_candidate?(node) do |options_node|
            options_node = options_node.first

            add_offense(node) if options_node.nil? || !includes_name?(options_node)
          end
        end

        private

        def includes_name?(node)
          node.pairs.any? { |p| p.key.value.to_sym == :name }
        end
      end
    end
  end
end
