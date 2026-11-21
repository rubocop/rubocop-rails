# frozen_string_literal: true

module RuboCop
  module Cop
    # A mixin for cops that read `db/schema.rb`. Including it makes RuboCop's result cache
    # depend on the schema, so only cops that actually use the schema should include it.
    module ActiveRecordSchemaChecksum
      def external_dependency_checksum
        return @external_dependency_checksum if defined?(@external_dependency_checksum)

        schema_path = RuboCop::Rails::SchemaLoader.db_schema_path
        return nil if schema_path.nil?

        schema_code = File.read(schema_path)

        @external_dependency_checksum ||= Digest::SHA1.hexdigest(schema_code)
      end
    end
  end
end
