# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Use `JSON.parse(json, symbolize_names: true)` instead of `JSON.parse(json).deep_symbolize_keys`.

      # Using `symbolize_names: true` is more efficient as it creates symbols during parsing
      # rather than requiring a second pass through the data structure.

      # @example
      #   # bad
      #   JSON.parse(json).deep_symbolize_keys
      #
      #   # good
      #   JSON.parse(json, symbolize_names: true)
      #
      class JSONSymbolizeNames < Base
        MSG = 'Use `symbolize_names` option.'

        RESTRICT_ON_SEND = %i[deep_symbolize_keys].to_set.freeze

        JSON_PARSING_METHOD_NAMES = %i[load_file load_file! parse parse!].to_set.freeze

        # @!method deep_symbolize_keys?(node)
        def_node_matcher :deep_symbolize_keys?, <<~PATTERN
          (call
            (send (const {nil? cbase} :JSON) JSON_PARSING_METHOD_NAMES ...) :deep_symbolize_keys)
        PATTERN

        def on_send(node)
          deep_symbolize_keys?(node) do
            add_offense(node)
          end
        end
        alias on_csend on_send
      end
    end
  end
end
