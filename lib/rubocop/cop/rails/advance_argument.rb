# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for invalid keyword arguments passed to `#advance`.
      #
      # The `#advance` method on date/time objects accepts specific keyword arguments.
      # Using singular forms (e.g., `hour:` instead of `hours:`) silently has no
      # effect, which is a common source of bugs.
      #
      # Valid keys for `Date#advance`: `:years`, `:months`, `:weeks`, `:days`
      #
      # Valid keys for `Time#advance`, `DateTime#advance`, and
      # `ActiveSupport::TimeWithZone#advance`: `:years`, `:months`, `:weeks`,
      # `:days`, `:hours`, `:minutes`, `:seconds`
      #
      # @example
      #   # bad - singular keys are silently ignored
      #   time.advance(hour: -1)
      #   date.advance(year: 1, month: 2)
      #
      #   # good
      #   time.advance(hours: -1)
      #   date.advance(years: 1, months: 2)
      #
      #   # bad - time-unit keys are not supported by `Date#advance`
      #   Date.today.advance(hours: 3)
      #
      #   # good
      #   Date.today.advance(days: 3)
      #
      class AdvanceArgument < Base
        extend AutoCorrector

        SINGULAR_TO_PLURAL = {
          year: :years,
          month: :months,
          week: :weeks,
          day: :days,
          hour: :hours,
          minute: :minutes,
          second: :seconds
        }.freeze

        TIME_ONLY_KEYS = Set[:hours, :minutes, :seconds].freeze

        MSG_SINGULAR = 'Invalid key `:%<key>s` for `#advance`. Did you mean `%<plural>s:`?'
        MSG_DATE_INCOMPATIBLE = '`%<key>s:` is not supported by `Date#advance`. ' \
                                'Use `years:`, `months:`, `weeks:`, or `days:` instead.'

        RESTRICT_ON_SEND = %i[advance].freeze

        def on_send(node)
          return unless (hash_node = advance_options(node))

          hash_node.pairs.each do |pair|
            next unless pair.key.sym_type?

            key_name = pair.key.value
            if (plural = SINGULAR_TO_PLURAL[key_name])
              add_singular_offense(pair, key_name, plural)
            elsif TIME_ONLY_KEYS.include?(key_name) && date_receiver?(node)
              add_date_incompatible_offense(pair, key_name)
            end
          end
        end
        alias on_csend on_send

        private

        def advance_options(node)
          last_arg = node.last_argument
          last_arg if last_arg&.hash_type?
        end

        def add_singular_offense(pair, key_name, plural)
          key_node = pair.key
          msg = format(MSG_SINGULAR, key: key_name, plural: plural)

          add_offense(key_node, message: msg) do |corrector|
            corrector.replace(key_node, corrected_key(pair, plural))
          end
        end

        def add_date_incompatible_offense(pair, key_name)
          key_node = pair.key
          msg = format(MSG_DATE_INCOMPATIBLE, key: key_name)
          add_offense(key_node, message: msg)
        end

        def corrected_key(pair, new_key)
          if pair.colon?
            new_key.to_s
          else
            ":#{new_key}"
          end
        end

        def date_receiver?(node)
          receiver = node.receiver
          return false unless receiver

          date_class_method?(receiver)
        end

        # @!method date_class_method?(node)
        #   Match a method call on the `Date` class (not `DateTime`) that returns a Date.
        #
        #   @param node [RuboCop::AST::Node]
        #   @return [Boolean]
        def_node_matcher :date_class_method?, <<~PATTERN
          (send (const {nil? cbase} :Date) {
            :today :current :yesterday :tomorrow
            :new :parse :civil :ordinal :jd :commercial :gregorian :julian
          } ...)
        PATTERN
      end
    end
  end
end
