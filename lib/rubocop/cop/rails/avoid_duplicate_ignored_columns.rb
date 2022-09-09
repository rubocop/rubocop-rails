# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for duplicate calls to ActiveRecord::Base.ignore_columns= as the
      # subsequent calls will override the first call.
      #
      # @example
      #   # bad
      #   class User < ApplicationRecord
      #     self.ignored_columns = %w(profile)
      #     self.ignored_columns = %w(birthday)
      #   end
      #
      #   # good
      #   class User < ApplicationRecord
      #     self.ignored_columns = %w(profile birthday)
      #   end
      #
      class AvoidDuplicateIgnoredColumns < Base
        MESSAGE = 'self.ignored_columns= has already been called on line %<other_line_number>s.'
        ACTIVE_RECORD_CLASSES = %w[ApplicationRecord ActiveRecord::Base].freeze

        def initialize(config = nil, options = nil)
          super

          @found_nodes = {}
          @reported_lines = []
        end

        def on_send(current_node)
          return unless current_node.method?(:ignored_columns=)
          return unless current_node.self_receiver?

          parent_class_name = find_parent_class_name(current_node)
          return unless active_model?(parent_class_name)

          @found_nodes[current_node.first_line] = current_node
          return if @found_nodes.size == 1

          add_offenses
        end

        private

        def active_model?(parent_class_name)
          ACTIVE_RECORD_CLASSES.include?(parent_class_name)
        end

        def find_parent_class_name(node)
          return nil unless node

          if node.class_type?
            parent_class_name = node.node_parts[1]

            return nil if parent_class_name.nil?

            return parent_class_name.source
          end

          find_parent_class_name(node.parent)
        end

        def add_offenses
          # Remove the earliest found node as we don't want to report offense on it.
          first_occurance_line_number = @found_nodes.keys.min
          @found_nodes.delete(first_occurance_line_number)

          @found_nodes.each do |line_number, node|
            next if @reported_lines.include?(line_number)

            add_offense(node, message: format(MESSAGE, other_line_number: first_occurance_line_number))

            @reported_lines << line_number
          end
        end
      end
    end
  end
end
