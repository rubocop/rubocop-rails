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
        include ActiveRecordHelper

        MESSAGE = '`self.ignored_columns=` has already been called on line %<other_line_number>s.'

        def initialize(config = nil, options = nil)
          super

          @found_nodes = {}
          @reported_lines = []
        end

        def on_send(node)
          return unless node.method?(:ignored_columns=)
          return unless node.self_receiver?
          return unless inherit_active_record_base?(node)

          @found_nodes[node.first_line] = node
          return if @found_nodes.size == 1

          add_offenses
        end

        private

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
