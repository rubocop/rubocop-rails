# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Detects when keys conversion methods are called on literal hashes, where it is redundant
      # or keys can be manually converted to the required type.
      #
      # @example
      #   # bad
      #   { a: 1, b: 2 }.symbolize_keys
      #
      #   # bad
      #   { a: 1, b: 2 }.stringify_keys
      #
      #   # good
      #   { 'a' => 1, 'b' => 2 }
      #
      #   # good
      #   { a: 1, var => 3 }.symbolize_keys
      #
      #   # good
      #   { a:, b: 2 }.stringify_keys
      #   { a: 1, b: foo }.deep_stringify_keys
      #
      class HashLiteralKeysConversion < Base
        extend AutoCorrector

        REDUNDANT_CONVERSION_MSG = 'Redundant hash keys conversion, all the keys have the required type.'
        MSG = 'Convert hash keys explicitly to the required type.'

        CONVERSION_METHODS = {
          symbolize_keys: :sym,
          symbolize_keys!: :sym,
          stringify_keys: :str,
          stringify_keys!: :str,
          deep_symbolize_keys: :sym,
          deep_symbolize_keys!: :sym,
          deep_stringify_keys: :str,
          deep_stringify_keys!: :str
        }.freeze

        RESTRICT_ON_SEND = CONVERSION_METHODS.keys

        def on_send(node)
          return unless (receiver = node.receiver)&.hash_type?

          type = CONVERSION_METHODS[node.method_name]
          deep = node.method_name.start_with?('deep_')
          return unless convertible_hash?(receiver, deep: deep)

          check(node, receiver, type: type, deep: deep)
        end

        # rubocop:disable Metrics/AbcSize
        def check(node, hash_node, type: :sym, deep: false)
          pair_nodes = pair_nodes(hash_node, deep: deep)

          type_pairs, other_pairs = pair_nodes.partition { |pair_node| pair_node.key.type == type }

          if type_pairs == pair_nodes
            add_offense(node.loc.selector, message: REDUNDANT_CONVERSION_MSG) do |corrector|
              corrector.remove(node.loc.dot)
              corrector.remove(node.loc.selector)
            end
          else
            add_offense(node.loc.selector) do |corrector|
              corrector.remove(node.loc.dot)
              corrector.remove(node.loc.selector)
              autocorrect_hash_keys(other_pairs, type, corrector)
            end
          end
        end
        # rubocop:enable Metrics/AbcSize

        private

        def convertible_hash?(node, deep: false)
          node.pairs.each do |pair|
            return false unless convertible_key?(pair)
            return false if deep && !convertible_node?(pair.value, deep: deep)
          end

          true
        end

        def convertible_key?(pair)
          key, _value = *pair

          (key.str_type? || key.sym_type?) && !pair.value_omission? && !key.value.match?(/\W/)
        end

        def convertible_array?(node, deep:)
          node.values.all? do |value|
            convertible_node?(value, deep: deep)
          end
        end

        def convertible_node?(node, deep:)
          if node.hash_type?
            convertible_hash?(node, deep: deep)
          elsif node.array_type?
            convertible_array?(node, deep: deep)
          else
            node.literal?
          end
        end

        def pair_nodes(hash_node, deep: false)
          if deep
            pair_nodes = []
            do_pair_nodes(hash_node, pair_nodes)
            pair_nodes
          else
            hash_node.pairs
          end
        end

        def do_pair_nodes(node, pair_nodes)
          if node.hash_type?
            node.pairs.each do |pair_node|
              pair_nodes << pair_node
              do_pair_nodes(pair_node.value, pair_nodes)
            end
          elsif node.array_type?
            node.each_value do |value|
              do_pair_nodes(value, pair_nodes)
            end
          end
        end

        def autocorrect_hash_keys(pair_nodes, type, corrector)
          pair_nodes.each do |pair_node|
            if type == :sym
              corrector.replace(pair_node.key, ":#{pair_node.key.value}")
            else
              corrector.replace(pair_node.key, "'#{pair_node.key.source}'")
            end

            corrector.replace(pair_node.loc.operator, '=>')
          end
        end
      end
    end
  end
end
