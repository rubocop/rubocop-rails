# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Identifies places where manually constructed SQL
      # in `where` can be replaced with ranges.
      #
      # @example
      #   # bad
      #   User.where('age >= ?', 18)
      #   User.where.not('age >= ?', 18)
      #   User.where('age < ?', 18)
      #   User.where('age >= ? AND age < ?', 18, 21)
      #   User.where('age >= :start', start: 18)
      #   User.where('users.age >= ?', 18)
      #
      #   # good
      #   User.where(age: 18..)
      #   User.where.not(age: 18..)
      #   User.where(age: ...18)
      #   User.where(age: 18...21)
      #   User.where(users: { age: 18.. })
      #
      #   # good
      #   # There are no beginless ranges in ruby.
      #   User.where('age > ?', 18)
      #
      class WhereRange < Base
        include RangeHelp
        extend AutoCorrector
        extend TargetRubyVersion
        extend TargetRailsVersion

        MSG = 'Use `%<good_method>s` instead of manually constructing SQL.'

        RESTRICT_ON_SEND = %i[where not].freeze

        # column >= ?
        GTEQ_ANONYMOUS_RE   = /\A([\w.]+)\s+>=\s+\?\z/.freeze
        # column <[=] ?
        LTEQ_ANONYMOUS_RE   = /\A([\w.]+)\s+(<=?)\s+\?\z/.freeze
        # column >= ? AND column <[=] ?
        RANGE_ANONYMOUS_RE  = /\A([\w.]+)\s+>=\s+\?\s+AND\s+\1\s+(<=?)\s+\?\z/i.freeze
        # column >= :value
        GTEQ_NAMED_RE       = /\A([\w.]+)\s+>=\s+:(\w+)\z/.freeze
        # column <[=] :value
        LTEQ_NAMED_RE       = /\A([\w.]+)\s+(<=?)\s+:(\w+)\z/.freeze
        # column >= :value1 AND column <[=] :value2
        RANGE_NAMED_RE      = /\A([\w.]+)\s+>=\s+:(\w+)\s+AND\s+\1\s+(<=?)\s+:(\w+)\z/i.freeze

        minimum_target_ruby_version 2.6
        minimum_target_rails_version 6.0

        def_node_matcher :where_range_call?, <<~PATTERN
          {
            (call _ {:where :not} (array $str_type? $_ +))
            (call _ {:where :not} $str_type? $_ +)
          }
        PATTERN

        def on_send(node)
          return if node.method?(:not) && !where_not?(node)

          where_range_call?(node) do |template_node, values_node|
            column, value = extract_column_and_value(template_node, values_node)

            return unless column

            range = offense_range(node)
            good_method = build_good_method(node.method_name, column, value)
            message = format(MSG, good_method: good_method)

            add_offense(range, message: message) do |corrector|
              corrector.replace(range, good_method)
            end
          end
        end

        private

        def where_not?(node)
          receiver = node.receiver
          receiver&.send_type? && receiver&.method?(:where)
        end

        # rubocop:disable Metrics
        def extract_column_and_value(template_node, values_node)
          value =
            case template_node.value
            when GTEQ_ANONYMOUS_RE
              "#{values_node[0].source}.."
            when LTEQ_ANONYMOUS_RE
              range_operator = range_operator(Regexp.last_match(2))
              "#{range_operator}#{values_node[0].source}" if target_ruby_version >= 2.7
            when RANGE_ANONYMOUS_RE
              if values_node.size >= 2
                range_operator = range_operator(Regexp.last_match(2))
                "#{values_node[0].source}#{range_operator}#{values_node[1].source}"
              end
            when GTEQ_NAMED_RE
              value_node = values_node[0]

              if value_node.hash_type?
                pair = find_pair(value_node, Regexp.last_match(2))
                "#{pair.value.source}.." if pair
              end
            when LTEQ_NAMED_RE
              value_node = values_node[0]

              if value_node.hash_type?
                pair = find_pair(value_node, Regexp.last_match(2))
                if pair && target_ruby_version >= 2.7
                  range_operator = range_operator(Regexp.last_match(2))
                  "#{range_operator}#{pair.value.source}"
                end
              end
            when RANGE_NAMED_RE
              value_node = values_node[0]

              if value_node.hash_type?
                range_operator = range_operator(Regexp.last_match(3))
                pair1 = find_pair(value_node, Regexp.last_match(2))
                pair2 = find_pair(value_node, Regexp.last_match(4))
                "#{pair1.value.source}#{range_operator}#{pair2.value.source}" if pair1 && pair2
              end
            end

          [Regexp.last_match(1), value] if value
        end
        # rubocop:enable Metrics

        def range_operator(comparison_operator)
          comparison_operator == '<' ? '...' : '..'
        end

        def find_pair(hash_node, value)
          hash_node.pairs.find { |pair| pair.key.value.to_sym == value.to_sym }
        end

        def offense_range(node)
          range_between(node.loc.selector.begin_pos, node.source_range.end_pos)
        end

        def build_good_method(method_name, column, value)
          if column.include?('.')
            table, column = column.split('.')

            "#{method_name}(#{table}: { #{column}: #{value} })"
          else
            "#{method_name}(#{column}: #{value})"
          end
        end
      end
    end
  end
end
