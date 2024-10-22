# typed: false
# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for custom index names in migrations.
      #
      # @safety
      #   Migration files must not be altered after they are run, and it is important to
      #   run identical migrations in each environment. Autocorrect should only be used
      #   while composing a migration, before executing it.
      #   See: https://guides.rubyonrails.org/active_record_migrations.html#changing-existing-migrations
      #
      # @example
      #   # bad
      #   class ExampleMigration < ActiveRecord::Migration[7.2]
      #     def change
      #       change_table :users do |t|
      #         t.index [:email], name: 'index_custom_name'
      #       end
      #     end
      #   end
      #
      #   # bad
      #   class ExampleMigration < ActiveRecord::Migration[7.2]
      #     def change
      #       add_index :table, :column, name: 'index_custom_name'
      #     end
      #   end
      #
      #   # good
      #   class ExampleMigration < ActiveRecord::Migration[7.2]
      #     def change
      #       create_table :users do |t|
      #         t.index [:email]
      #       end
      #     end
      #   end
      #
      #   # ok (custom name may differentiate this index from an index on the same columns with default order)
      #   class ExampleMigration < ActiveRecord::Migration[7.2]
      #     def change
      #       create_table :robots do |t|
      #         t.index [:priority, :created_at],
      #           name: 'index_robots_by_recency',
      #           order: { priority: "ASC NULLS LAST", created_at: :asc }
      #       end
      #     end
      #   end
      #
      #   # ok (custom name may be necessary to meet DB character limit for index names in older Rails versions)
      #   class ExampleMigration < ActiveRecord::Migration[7.0]
      #     def change
      #       create_table :users do |t|
      #         t.index [:email], name: 'index_custom_name'
      #       end
      #     end
      #   end
      #
      class IndexNames < Base
        include MigrationsHelper
        include RangeHelp
        extend AutoCorrector
        extend TargetRailsVersion

        minimum_target_rails_version 7.1

        MSG = 'Avoid specifying a custom name for common indexes. Let Rails handle the index name automatically.'
        RESTRICT_ON_SEND = %i[index add_index].freeze
        # Keys that do not justify a duplicative index or a custom name, as they represent stricter column conditions.:
        # unique, length, nulls_not_distinct
        # Refer to: https://github.com/rails/rails/blob/b943622bdc746370ac860bfd3240cc0b8ca59d90/activerecord/lib/active_record/connection_adapters/abstract/schema_statements.rb#L1477
        VALID_REASONS_FOR_CUSTOM_NAME = Set.new(%i[where type using comment algorithm include opclass order]).freeze

        def on_send(node)
          return unless node.last_argument&.hash_type?
          return unless in_supported_migration?(node, 7.1)
          return unless (name_pair = find_name_pair(node))

          return if node.last_argument.pairs.any? { |pair| VALID_REASONS_FOR_CUSTOM_NAME.include?(pair.key.value) }

          add_offense(node) do |corrector|
            remove_name_argument(corrector, name_pair, node)
          end
        end

        private

        def find_name_pair(node)
          node.last_argument.pairs.find { |pair| pair.key.value == :name || pair.key.value == 'name' }
        end

        def remove_name_argument(corrector, name_pair, node)
          range = name_argument_range(name_pair, node)
          corrector.remove(range)
          remove_extra_comma_and_space(corrector, range, node)
        end

        def name_argument_range(name_pair, node)
          hash_node = name_pair.parent
          if hash_node.pairs.size == 1
            # If name: is the only argument, remove the entire hash
            range_between(node.arguments[-2].source_range.end_pos, node.source_range.end_pos)
          else
            # Remove the name: argument and any preceding comma and space
            start_pos = previous_comma_pos(name_pair) || name_pair.source_range.begin_pos
            range_between(start_pos, name_pair.source_range.end_pos)
          end
        end

        def previous_comma_pos(pair)
          source = pair.parent.source
          pair_start = pair.source_range.begin_pos - pair.parent.source_range.begin_pos
          previous_content = source[0...pair_start]
          comma_index = previous_content.rindex(',')
          comma_index ? pair.parent.source_range.begin_pos + comma_index : nil
        end

        def remove_extra_comma_and_space(corrector, removed_range, node)
          remaining_source = remaining_source(node, removed_range)
          next_relevant_content = remaining_source.lstrip
          range_to_remove = if next_relevant_content.start_with?(',')
                              space_after_comma(removed_range, next_relevant_content)
                            else
                              leading_space(remaining_source, removed_range)
                            end

          corrector.remove(range_to_remove)
        end

        def remaining_source(node, removed_range)
          node.source[removed_range.end_pos - node.source_range.begin_pos..]
        end

        def space_after_comma(removed_range, next_relevant_content)
          space_after_comma = next_relevant_content[1..].match(/\A\s*/)[0]
          range_between(removed_range.end_pos, removed_range.end_pos + 1 + space_after_comma.length)
        end

        def leading_space(remaining_source, removed_range)
          leading_space = remaining_source.match(/\A\s*/)[0]
          range_between(removed_range.end_pos, removed_range.end_pos + leading_space.length)
        end
      end
    end
  end
end
