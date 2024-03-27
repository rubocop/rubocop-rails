# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Looks for enums written with keyword arguments.
      #
      # Defining enums with keyword arguments is deprecated
      # and will be removed in Rails 7.3.
      #
      # Positional arguments should be used instead:
      #
      # @example
      #   # bad
      #   enum status: { active: 0, archived: 1 }, _prefix: true
      #
      #   # good
      #   enum :status, { active: 0, archived: 1 }, prefix: true
      #
      class EnumKeywordArgs < Base
        extend AutoCorrector

        MSG_ARGS = <<~MSG.chomp
          Enum defined with keyword arguments found in `%<enum>s` enum declaration. Use positional arguments instead.
        MSG
        MSG_OPTS = <<~MSG.chomp
          Enum defined with deprecated options found in `%<enum>s` enum declaration. Use options without the `_` prefix.
        MSG

        RESTRICT_ON_SEND = %i[enum].freeze

        def_node_matcher :enum?, <<~PATTERN
          (send nil? :enum (hash $...))
        PATTERN

        def_node_matcher :enum_with_options?, <<~PATTERN
          (send nil? :enum $_ ${array hash} $_)
        PATTERN

        def_node_matcher :enum_values, <<~PATTERN
          (pair $_ ${array hash})
        PATTERN

        def_node_matcher :enum_options, <<~PATTERN
          (pair $_ $_)
        PATTERN

        def on_send(node)
          check_and_correct_keyword_args(node)
          check_enum_options(node)
        end

        private

        def check_and_correct_keyword_args(node)
          enum?(node) do |pairs|
            pairs.each do |pair|
              key, values = enum_values(pair)
              next unless key

              correct_keyword_args(node, key, values, pairs[1..])
            end
          end
        end

        def correct_keyword_args(node, key, values, options)
          add_offense(values, message: format(MSG_ARGS, enum: enum_name(key))) do |corrector|
            corrector.replace(node, "enum #{source(key)}, #{values.source}#{correct_options(options)}")
          end
        end

        def correct_options(options)
          corrected_options = options.map do |pair|
            name = if pair.key.source[0] == '_'
                     pair.key.source[1..]
                   else
                     pair.key.source
                   end

            "#{name}: #{pair.value.source}"
          end.join(', ')
          ", #{corrected_options}" unless corrected_options.empty?
        end

        def check_enum_options(node)
          enum_with_options?(node) do |key, _, options|
            options.children.each do |option|
              name, = enum_options(option)
              add_offense(name, message: format(MSG_OPTS, enum: enum_name(key))) if name.source[0] == '_'
            end
          end
        end

        def enum_name(key)
          case key.type
          when :sym, :str
            key.value
          else
            key.source
          end
        end

        def source(elem)
          case elem.type
          when :str
            elem.value.dump
          when :sym
            elem.value.inspect
          else
            elem.source
          end
        end
      end
    end
  end
end
