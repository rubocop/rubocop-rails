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
            (float $_))
          _)
      PATTERN

      def in_migration?(node)
        node.each_ancestor(:class).any? do |class_node|
          migration_class?(class_node)
        end
      end

      def in_supported_migration?(node, minimum_version)
        node.each_ancestor(:class).any? do |class_node|
          migration_class?(class_node) do |version|
            version >= minimum_version
          end
        end
      end
    end
  end
end
