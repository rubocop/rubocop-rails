# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Use `JSON.parse(json, symbolize_names: true)` instead of `JSON.parse(json).deep_symbolize_keys`.
      # Using `symbolize_names: true` is more efficient as it creates symbols during parsing
      # rather than requiring a second pass through the data structure.
      #
      # @example
      #   # bad
      #   JSON.parse(json).deep_symbolize_keys
      #
      #   # good
      #   JSON.parse(json, symbolize_names: true)
      #
      #   # good
      #   JSON.parse(json, create_additions: true).deep_symbolize_keys
      #
      class JSONSymbolizeNames < Base
        extend AutoCorrector

        MSG = 'Use `symbolize_names` option.'
        RESTRICT_ON_SEND = %i[deep_symbolize_keys].to_set.freeze
        JSON_PARSING_METHOD_NAMES = %i[load_file load_file! parse parse!].to_set.freeze

        # @!method deep_symbolize_keys?(node)
        def_node_matcher :deep_symbolize_keys?, <<~PATTERN
          (call
            (send (const {nil? cbase} :JSON) JSON_PARSING_METHOD_NAMES ...) :deep_symbolize_keys)
        PATTERN

        # @!method create_additions_true?(node)
        def_node_matcher :create_additions_true?, <<~PATTERN
          (pair (sym :create_additions) (true))
        PATTERN

        def on_send(node)
          deep_symbolize_keys?(node) do
            json_parse_node = node.receiver

            next if create_additions_enabled?(json_parse_node)

            handle_offense(node, json_parse_node)
          end
        end
        alias on_csend on_send

        private

        def create_additions_enabled?(json_parse_node)
          json_parse_node.arguments.any? do |arg|
            next false unless arg.hash_type?

            arg.pairs.any? { |pair| create_additions_true?(pair) }
          end
        end

        def handle_offense(node, json_parse_node)
          add_offense(node) do |corrector|
            range_to_remove = json_parse_node.source_range.end.join(node.source_range.end)
            corrector.remove(range_to_remove)

            if json_parse_node.arguments.any?
              corrector.insert_after(json_parse_node.last_argument, ', symbolize_names: true')
            else
              corrector.insert_after(json_parse_node.source_range.end.adjust(begin_pos: -1), 'symbolize_names: true')
            end
          end
        end
      end
    end
  end
end
