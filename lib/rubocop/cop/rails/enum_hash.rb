# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for enums written with array syntax.
      #
      # When using array syntax, adding an element in a
      # position other than the last causes all previous
      # definitions to shift. Explicitly specifying the
      # value for each key prevents this from happening.
      #
      # @example
      #   # bad
      #   enum status: [:active, :archived]
      #
      #   # good
      #   enum status: { active: 0, archived: 1 }
      #
      class EnumHash < Cop
        MSG = 'Enum defined as an array found in `%<enum>s` enum declaration. '\
              'Use hash syntax instead.'

        def_node_matcher :enum?, <<~PATTERN
          (send nil? :enum (hash $...))
        PATTERN

        def_node_matcher :array_pair?, <<~PATTERN
          (pair $_ $array)
        PATTERN

        def on_send(node)
          enum?(node) do |pairs|
            pairs.each do |pair|
              key, array = array_pair?(pair)
              next unless key

              add_offense(array, message: format(MSG, enum: enum_name(key)))
            end
          end
        end

        private

        def enum_name(key)
          case key.type
          when :sym, :str
            key.value
          else
            key.source
          end
        end

        def autocorrect(node)
          enum_values = node.children[2].children.first.children[1]
          to_replace = enum_values.loc.expression
          values_hash = "{ #{converted_values(enum_values)} }"

          ->(corrector) { corrector.replace(to_replace, values_hash) }
        end

        private

        def converted_values(enum_values)
          enum_values.children.each_with_index.map do |child, index|
            hash_entry_as_string(child, index)
          end.join(', ')
        end

        def hash_entry_as_string(child, index)
          value = child.children.first
          case value
          when String
            "'#{value}' => #{index}"
          when Symbol
            value = "'#{value}'" if value =~ /\s/
            "#{value}: #{index}"
          else
            "#{child.source} => #{index}"
          end
        end
      end
    end
  end
end
