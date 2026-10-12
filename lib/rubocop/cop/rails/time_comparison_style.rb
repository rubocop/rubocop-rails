# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces either `before?` and `after?`, or `<` and `>` for comparisons with relative time.
      #
      # Only comparisons where one side is evidently a time are checked,
      # such as `3.days.ago` or `Time.current - 3.days`.
      # Comparisons with the current time itself are handled by `Rails/TimeComparison`.
      #
      # RSpec `be` matchers, such as `be > 1.day.ago`, are ignored.
      # Safe navigation comparisons (`&.>`), comparisons of `begin` blocks, and, with the `comparison` style,
      # arguments of operators that bind tighter than `<`, such as `results << time.before?(3.days.ago)`,
      # are registered, but not autocorrected.
      #
      # @example EnforcedStyle: comparison (default)
      #   # bad
      #   user.created_at.after?(3.hours.ago)
      #   user.created_at.before?(2.weeks.ago)
      #   replies_count_cache_updated_at.after?(5.minutes.ago)
      #
      #   # good
      #   user.created_at > 3.hours.ago
      #   user.created_at < 2.weeks.ago
      #   replies_count_cache_updated_at > 5.minutes.ago
      #
      # @example EnforcedStyle: relative
      #   # bad
      #   recency_bonus = usable_date > 12.hours.ago ? 280 : 0
      #   silenced_till > 100.years.from_now
      #   5.minutes.from_now < expires_at
      #   params[:before] < 10.years.ago || params[:before] > 1.week.ago
      #
      #   # good
      #   recency_bonus = usable_date.after?(12.hours.ago) ? 280 : 0
      #   silenced_till.after?(100.years.from_now)
      #   expires_at.after?(5.minutes.from_now)
      #   params[:before].before?(10.years.ago) || params[:before].after?(1.week.ago)
      #
      class TimeComparisonStyle < Base
        include ConfigurableEnforcedStyle
        include TimeComparisonHelper
        extend AutoCorrector

        MSG = 'Use `%<prefer>s` instead.'

        RESTRICT_ON_SEND = %i[< > before? after?].freeze

        METHODS = { :< => :before?, :> => :after? }.freeze

        SWAPPED_METHODS = { :< => :after?, :> => :before? }.freeze

        OPERATORS = METHODS.invert.freeze

        TIGHTER_OPERATORS = %i[<< >> & | ^ + - * / % **].to_set.freeze

        DURATION_UNITS = Set[
          :second, :seconds, :minute, :minutes, :hour, :hours, :day, :days, :week, :weeks,
          :fortnight, :fortnights, :month, :months, :year, :years
        ].freeze

        # @!method duration?(node)
        def_node_matcher :duration?, '(send {int float} DURATION_UNITS)'

        # @!method relative_time?(node)
        def_node_matcher :relative_time?, <<~PATTERN
          {
            (send #duration? {:ago :from_now :since :until})
            (send #current_time? {:+ :-} #duration?)
          }
        PATTERN

        def on_send(node)
          return unless node.receiver && node.arguments.one?

          if node.operator_method?
            check_operator(node) if style == :relative
          elsif style == :comparison
            check_method(node)
          end
        end
        alias on_csend on_send

        private

        def check_operator(node)
          time, method, relative = relative_comparison(node)
          return if time.nil? || arithmetic?(time) || rspec_be?(time)

          if time.kwbegin_type?
            register_offense(node, method, nil)
          else
            prefer = "#{time.source}#{node.csend_type? ? '&.' : '.'}#{method}(#{relative.source})"
            register_offense(node, prefer, node.csend_type? ? nil : prefer)
          end
        end

        def relative_comparison(node)
          left = node.receiver
          right = node.first_argument

          if relative_time?(right)
            [left, METHODS[node.method_name], right]
          elsif relative_time?(left) && !safe_navigation?(right)
            [right, SWAPPED_METHODS[node.method_name], left]
          end
        end

        def check_method(node)
          return if node.csend_type?
          return unless relative_time?(node.receiver) || relative_time?(node.first_argument)

          prefer = "#{node.receiver.source} #{OPERATORS[node.method_name]} #{node.first_argument.source}"
          replacement = if tighter_operator_argument?(node)
                          nil
                        elsif operator_receiver?(node)
                          "(#{prefer})"
                        else
                          prefer
                        end
          register_offense(node, prefer, replacement)
        end

        # `results << time.before?(3.days.ago)` would become `(results << time) < 3.days.ago`
        def tighter_operator_argument?(node)
          parent = node.parent
          parent&.call_type? && TIGHTER_OPERATORS.include?(parent.method_name) && !node.equal?(parent.receiver)
        end

        def operator_receiver?(node)
          node.parent&.call_type? && node.equal?(node.parent.receiver)
        end
      end
    end
  end
end
