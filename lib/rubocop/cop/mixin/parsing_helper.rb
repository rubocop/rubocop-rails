# frozen_string_literal: true

module RuboCop
  module Cop
    # A mixin with helpers related to source code parsing
    module ParsingHelper
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
