# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops working with migrations
    module MigrationsHelper
      extend NodePattern::Macros

      def_node_matcher :migration_class?, <<~PATTERN
        (class
          (const {nil? cbase} _)
          (send
            (const (const {nil? cbase} :ActiveRecord) :Migration)
            :[]
            (float _))
          _)
      PATTERN

      def in_migration?(node)
        node.each_ancestor(:class).any? do |class_node|
          migration_class?(class_node)
        end
      end

      # rubocop:disable Style/DocumentDynamicEvalDefinition
      %i[on_send on_csend on_block on_numblock on_class].each do |method|
        class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
          def #{method}(node)
            return if already_migrated_file?

            super if method(__method__).super_method
          end
        RUBY
      end
      # rubocop:enable Style/DocumentDynamicEvalDefinition

      private

      def already_migrated_file?
        return false unless migrated_schema_version

        match_data = File.basename(processed_source.file_path).match(/(?<timestamp>\d{14})/)
        schema_version = match_data['timestamp'] if match_data

        return false unless schema_version

        schema_version <= migrated_schema_version.to_s # Ignore applied migration files.
      end

      def migrated_schema_version
        config.for_all_cops.fetch('MigratedSchemaVersion', nil)
      end
    end
  end
end
