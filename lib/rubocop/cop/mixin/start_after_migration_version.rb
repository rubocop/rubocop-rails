# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for migrations-related cops to check after specific migration version.
    module StartAfterMigrationVersion
      private

      def starts_after_migration_version?
        return true if start_after_migration_version.nil?

        file_path = processed_source.file_path
        basename = File.basename(file_path, '.rb')
        migration_number = basename[/^\d+/].to_i
        migration_number > start_after_migration_version
      end

      def start_after_migration_version
        version = cop_config['StartAfterMigrationVersion']
        return unless version

        version.to_i
      end
    end
  end
end
