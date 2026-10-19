# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for comparisons of time with the current time.
      # Use `past?` and `future?` instead.
      #
      # A duration added to or subtracted from the time is moved to the other side of the comparison,
      # but only if it is in seconds, minutes or hours. A day is not always 24 hours long (DST),
      # and a month or a year is not reversible (Jan 31 + 1 month is Feb 28, and Feb 28 - 1 month is Jan 28),
      # so comparisons with these durations are ignored.
      # Non-strict comparisons (`<=`, `>=`), and comparisons with `Date.current` are ignored, too.
      #
      # @example
      #   # bad
      #   grand_opening_at < Time.current
      #   Time.zone.now > grand_opening_at
      #   grand_opening_at.before?(Time.current)
      #   public_release_at > Time.current
      #   public_release_at.after?(Time.current)
      #   Time.current.before?(public_release_at)
      #
      #   # good
      #   grand_opening_at.past?
      #   public_release_at.future?
      #
      #   # bad
      #   last_attempt_at + 1.hour < Time.current
      #   Time.current - last_attempt_at > 1.hour
      #   (last_attempt_at + 1.hour).before?(Time.current)
      #   (last_attempt_at + 1.hour).past?
      #
      #   # good
      #   last_attempt_at < 1.hour.ago
      #   last_attempt_at.before?(1.hour.ago)
      #
      class TimeComparison < Base
        include TimeComparisonHelper
        extend AutoCorrector

        MSG = 'Use `%<prefer>s` instead.'

        RESTRICT_ON_SEND = %i[< > before? after? past? future?].freeze

        EARLIER_METHODS = %i[< before? past?].freeze

        ABSOLUTE_UNITS = Set[:second, :seconds, :minute, :minutes, :hour, :hours].freeze

        RELATIVE_METHODS = { :+ => 'ago', :- => 'from_now' }.freeze

        # @!method absolute_duration?(node)
        def_node_matcher :absolute_duration?, '(send {int float} ABSOLUTE_UNITS)'

        # @!method shifted_time(node)
        def_node_matcher :shifted_time, '(send $_ ${:+ :-} $#absolute_duration?)'

        # @!method elapsed_time(node)
        def_node_matcher :elapsed_time, '(send #current_time? :- $_)'

        def on_send(node)
          if node.arguments.none?
            check_predicate(node)
          elsif node.arguments.one?
            check_comparison(node)
          end
        end
        alias on_csend on_send

        private

        def check_predicate(node)
          return unless node.receiver

          check_shift(node, node.receiver, EARLIER_METHODS.include?(node.method_name))
        end

        def check_comparison(node)
          if current_time?(node.first_argument)
            check_compared(node, node.receiver, current_time_first: false)
          elsif current_time?(node.receiver)
            check_compared(node, node.first_argument, current_time_first: true)
          else
            check_elapsed(node)
          end
        end

        def check_compared(node, time, current_time_first:)
          earlier = EARLIER_METHODS.include?(node.method_name) ^ current_time_first

          if arithmetic?(time)
            check_shift(node, time, earlier)
          elsif !rspec_be?(time) && !(current_time_first && safe_navigation?(time))
            register_offense(node, "#{time.source}#{dot(node, time)}#{earlier ? 'past?' : 'future?'}")
          end
        end

        def check_shift(node, shifted, earlier)
          time, operator, duration = shifted_time(unwrap(shifted))
          return if time.nil? || arithmetic?(time)

          relative = "#{duration.source}.#{RELATIVE_METHODS[operator]}"
          prefer = if node.operator_method?
                     "#{time.source} #{earlier ? '<' : '>'} #{relative}"
                   else
                     "#{time.source}.#{earlier ? 'before?' : 'after?'}(#{relative})"
                   end

          register_offense(node, prefer)
        end

        def check_elapsed(node)
          time, duration, elapsed_first = elapsed_comparison(node)
          return if time.nil? || safe_navigation?(time)

          earlier = node.method?(:>) == elapsed_first
          register_offense(node, "#{time.source} #{earlier ? '<' : '>'} #{duration.source}.ago")
        end

        def elapsed_comparison(node)
          if absolute_duration?(node.first_argument) && (time = elapsed_time(unwrap(node.receiver)))
            [time, node.first_argument, true]
          elsif absolute_duration?(node.receiver) && (time = elapsed_time(unwrap(node.first_argument)))
            [time, node.receiver, false]
          end
        end

        def dot(node, time)
          node.csend_type? && time.equal?(node.receiver) ? '&.' : '.'
        end
      end
    end
  end
end
