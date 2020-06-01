# frozen_string_literal: true

# FIXME: Do not merge until `after_teardown` is handled or worked around

module RuboCop
  module Cop
    module Rails
      # This cop disallows all usage of `Timecop`, in favour of
      # `ActiveSupport::Testing::TimeHelpers`.
      #
      # ## Migration
      # `Timecop.freeze` should be replaced with `freeze_time` when used
      # without arguments. Where a `duration` has been passed to `freeze`, it
      # should be replaced with `travel`. Likewise, where a `time` has been
      # passed to `freeze`, it should be replaced with `travel_to`.
      #
      # `Timecop.return` should be replaced with `travel_back`, when used
      # without a block. `travel_back` does not accept a block, so where
      # `return` is used with a block, it should be replaced by explicitly
      # calling `freeze_time` with a block, and passing the `time` to
      # temporarily return to.
      #
      # `Timecop.scale` should be replaced by explicitly calling `travel` or
      # `travel_to` with the expected `durations` or `times`, respectively,
      # rather than relying on allowing time to continue to flow.
      #
      # `Timecop.travel` should be replaced by `travel` or `travel_to` when
      # passed a `duration` or `time`, respectively. As with `Timecop.scale`,
      # rather than relying on time continuing to flow, it should be travelled
      # to explicitly.
      #
      # All other usages of `Timecop` are similarly disallowed.
      #
      # ## Caveats
      #
      # Note that if using RSpec, `TimeHelpers` are not included by default,
      # and must be manually included by updating `spec_helper` (or
      # `rails_helper`):
      #
      # ```ruby
      # RSpec.configure do |config|
      #   config.include ActiveSupport::Testing::TimeHelpers
      # end
      # ```
      #
      # @example
      #   # bad
      #   Timecop
      #
      #   # bad
      #   Timecop.freeze
      #   Timecop.freeze(duration)
      #   Timecop.freeze(time)
      #
      #   # good
      #   freeze_time
      #   travel(duration)
      #   travel_to(time)
      #
      #   # bad
      #   Timecop.freeze { assert true }
      #   Timecop.freeze(duration) { assert true }
      #   Timecop.freeze(time) { assert true }
      #
      #   # good
      #   freeze_time { assert true }
      #   travel(duration) { assert true }
      #   travel_to(time) { assert true }
      #
      #   # bad
      #   Timecop.travel(duration)
      #   Timecop.travel(time)
      #
      #   # good
      #   travel(duration)
      #   travel_to(time)
      #
      #   # bad
      #   Timecop.return
      #   Timecop.return { assert true }
      #
      #   # good
      #   travel_back
      #   travel_to(time) { assert true }
      #
      # FIXME: Do not merge until `after_teardown` is handled or worked around
      class Timecop < Cop
        FREEZE_MESSAGE =
          'Use `freeze_time` instead of `Timecop.freeze`'.freeze
        FREEZE_WITH_ARGUMENTS_MESSAGE =
          'Use `travel` or `travel_to` instead of `Timecop.freeze`'.freeze
        RETURN_MESSAGE =
          'Use `travel_back` instead of `Timecop.return`'.freeze
        TRAVEL_MESSAGE =
          'Use `travel` or `travel_to` instead of `Timecop.travel`. If you ' \
          'need time to keep flowing, simulate it by travelling again.'.freeze
        MSG =
          'Use `ActiveSupport::Testing::TimeHelpers` instead of ' \
          '`Timecop`'.freeze

        FREEZE_TIME = 'freeze_time'.freeze
        TRAVEL_BACK = 'travel_back'.freeze

        def_node_matcher :timecop, <<-PATTERN.strip_indent
          (const {nil? cbase} :Timecop)
        PATTERN

        def_node_matcher :timecop_send, <<-PATTERN.strip_indent
          (send
            #timecop ${:freeze :return :travel}
            $...
          )
        PATTERN

        def on_const(node)
          return unless timecop(node)

          timecop_send(node.parent) do |message, arguments|
            return on_timecop_send(node.parent, message, arguments)
          end

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            timecop_send(node) do |message, arguments|
              case message
              when :freeze
                autocorrect_freeze(corrector, node, arguments)
              when :return
                autocorrect_return(corrector, node, arguments)
              end
            end
          end
        end

        private

        def on_timecop_send(node, message, arguments)
          case message
          when :freeze
            on_timecop_freeze(node, arguments)
          when :return
            on_timecop_return(node, arguments)
          when :travel
            on_timecop_travel(node, arguments)
          else
            add_offense(node)
          end
        end

        def on_timecop_freeze(node, arguments)
          if arguments.empty?
            add_offense(node, message: FREEZE_MESSAGE)
          else
            add_offense(node, message: FREEZE_WITH_ARGUMENTS_MESSAGE)
          end
        end

        def on_timecop_return(node, _arguments)
          add_offense(node, message: RETURN_MESSAGE)
        end

        def on_timecop_travel(node, _arguments)
          add_offense(node, message: TRAVEL_MESSAGE)
        end

        def autocorrect_freeze(corrector, node, arguments)
          return unless arguments.empty?

          corrector.replace(receiver_and_message_range(node), FREEZE_TIME)
        end

        def autocorrect_return(corrector, node, _arguments)
          return if was_passed_block?(node)

          corrector.replace(receiver_and_message_range(node), TRAVEL_BACK)
        end

        def was_passed_block?(node)
          node.send_type? && node.parent &&
            node.parent.block_type? && node.parent.send_node == node
        end

        def receiver_and_message_range(node)
          node.location.expression.with(end_pos: node.location.selector.end_pos)
        end
      end
    end
  end
end
