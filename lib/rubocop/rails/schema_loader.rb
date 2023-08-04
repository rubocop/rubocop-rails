# frozen_string_literal: true

module RuboCop
  module Rails
    # It loads db/schema.rb and return Schema object.
    # Cops refers database schema information with this module.
    module SchemaLoader
      extend self

      # It parses schema file at  and return it.
      # It returns `nil` if it can't find the schema file.
      # So a cop that uses the loader should handle `nil` properly.
      # @param target_ruby_version [String] The target Ruby version
      # @param schema_path [String] The path to the schema file, defaults to `db/schema.rb`
      #
      # @return [Schema, nil]
      def load(target_ruby_version, schema_path = 'db/schema.rb')
        return @load if defined?(@load)

        @schema_path = schema_path
        @load = load!(target_ruby_version)
      end

      def reset!
        remove_instance_variable(:@schema_path) if instance_variable_defined?(:@schema_path)
        remove_instance_variable(:@load) if instance_variable_defined?(:@load)
      end

      def db_schema_path
        path = Pathname.pwd
        until path.root?
          schema_path = path.join(@schema_path || 'db/schema.rb')
          return schema_path if schema_path.exist?

          path = path.join('../').cleanpath
        end

        nil
      end

      private

      def load!(target_ruby_version)
        path = db_schema_path
        return unless path

        ast = parse(path, target_ruby_version)
        Schema.new(ast) if ast
      end

      def parse(path, target_ruby_version)
        klass_name = :"Ruby#{target_ruby_version.to_s.sub('.', '')}"
        klass = ::Parser.const_get(klass_name)
        parser = klass.new(RuboCop::AST::Builder.new)

        buffer = Parser::Source::Buffer.new(path, 1)
        buffer.source = path.read

        parser.parse(buffer)
      end
    end
  end
end
