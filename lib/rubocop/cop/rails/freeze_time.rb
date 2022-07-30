# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Identifies usages of `travel_to` with an argument of the current time and
      # change them to use `freeze_time` instead.
      #
      # @safety
      #   This cop’s autocorrection is unsafe because `freeze_time` just delegates to
      #   `travel_to` with a default `Time.now`, it is not strictly equivalent to `Time.now`
      #   if the argument of `travel_to` is the current time considering time zone.
      #
      # @example
      #   # bad
      #   travel_to(Time.now)
      #   travel_to(Time.new)
      #   travel_to(DateTime.now)
      #   travel_to(Time.current)
      #   travel_to(Time.zone.now)
      #   travel_to(Time.now.in_time_zone)
      #   travel_to(Time.current.to_time)
      #
      #   # good
      #   freeze_time
      #
      class FreezeTime < Base
        extend AutoCorrector

        MSG = 'Use `freeze_time` instead of `travel_to`.'
        NOW_METHODS = %i[now new current].freeze
        CONV_METHODS = %i[to_time in_time_zone].freeze
        RESTRICT_ON_SEND = %i[travel_to].freeze

        # @!method time_now?(node)
        def_node_matcher :time_now?, <<~PATTERN
          (const nil? {:Time :DateTime})
        PATTERN

        # @!method zoned_time_now?(node)
        def_node_matcher :zoned_time_now?, <<~PATTERN
          (send (const nil? :Time) :zone)
        PATTERN

        def on_send(node)
          child_node, method_name = *node.first_argument.children
          return unless current_time?(child_node, method_name) || current_time_with_convert?(child_node, method_name)

          add_offense(node) { |corrector| corrector.replace(node, 'freeze_time') }
        end

        private

        def current_time?(node, method_name)
          return false unless NOW_METHODS.include?(method_name)

          node.send_type? ? zoned_time_now?(node) : time_now?(node)
        end

        def current_time_with_convert?(node, method_name)
          return false unless CONV_METHODS.include?(method_name)

          child_node, child_method_name = *node.children
          current_time?(child_node, child_method_name)
        end
      end
    end
  end
end
