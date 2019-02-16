# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Disallows all usage of `Timecop`, in favour of
      # `ActiveSupport::Testing::TimeHelpers`.
      #
      # ## Migration
      # `Timecop.freeze` should be replaced with `freeze_time` when used
      # without arguments. Where a `duration` has been passed to `freeze`, it
      # should be replaced with `travel`. Likewise, where a `time` has been
      # passed to `freeze`, it should be replaced with `travel_to`.
      #
      # `Timecop.scale` should be replaced by explicitly calling `travel` or
      # `travel_to` with the expected `durations` or `times`, respectively,
      # rather than relying on allowing time to continue to flow.
      #
      # `Timecop.return` should be replaced with `travel_back`, when used
      # without a block. `travel_back` does not accept a block, so where
      # `return` is used with a block, it should be replaced by explicitly
      # calling `freeze_time` with a block, and passing the `time` to
      # temporarily return to.
      #
      # `Timecop.travel` should be replaced by `travel` or `travel_to` when
      # passed a `duration` or `time`, respectively. As with `Timecop.scale`,
      # rather than relying on time continuing to flow, it should be travelled
      # to explicitly.
      #
      # All other usages of `Timecop` are similarly disallowed.
      #
      # ## RSpec Caveats
      #
      # Note that if using RSpec, `TimeHelpers` are not included by default,
      # and must be manually included by updating `rails_helper` accordingly:
      #
      # ```ruby
      # RSpec.configure do |config|
      #   config.include ActiveSupport::Testing::TimeHelpers
      # end
      # ```
      #
      # Moreover, because `TimeHelpers` relies on Minitest teardown hooks,
      # `rails_helper` must be required (instead of `spec_helper`), or a
      # similar adapter layer must be in effect.
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
      #   # bad
      #   Timecop.scale(factor)
      #   Timecop.scale(factor) { assert true }
      #
      #   # good
      #   travel(duration)
      #   travel_to(time)
      #   travel(duration) { assert true }
      #   travel_to(time) { assert true }
      class Timecop < Base
        extend AutoCorrector

        FREEZE_MESSAGE = 'Use `%<replacement>s` instead of `Timecop.freeze`'
        FREEZE_WITH_ARGUMENTS_MESSAGE = 'Use `travel` or `travel_to` instead of `Timecop.freeze`'
        RETURN_MESSAGE = 'Use `%<replacement>s` instead of `Timecop.return`'
        FLOW_ADDENDUM = 'If you need time to keep flowing, simulate it by travelling again.'
        TRAVEL_MESSAGE = "Use `travel` or `travel_to` instead of `Timecop.travel`. #{FLOW_ADDENDUM}"
        SCALE_MESSAGE = "Use `travel` or `travel_to` instead of `Timecop.scale`. #{FLOW_ADDENDUM}"
        MSG = 'Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`'

        def_node_matcher :timecop_const?, <<~PATTERN
          (const {nil? cbase} :Timecop)
        PATTERN

        def_node_matcher :timecop_send, <<~PATTERN
          (send
            #timecop_const? ${:freeze :return :scale :travel}
            $...
          )
        PATTERN

        def on_const(node)
          return unless timecop_const?(node)

          timecop_send(node.parent) do |message, arguments|
            return on_timecop_send(node.parent, message, arguments)
          end

          add_offense(node)
        end

        private

        def on_timecop_send(node, message, arguments)
          case message
          when :freeze then on_timecop_freeze(node, arguments)
          when :return then on_timecop_return(node, arguments)
          when :scale  then on_timecop_scale(node, arguments)
          when :travel then on_timecop_travel(node, arguments)
          else add_offense(node)
          end
        end

        def on_timecop_freeze(node, arguments)
          if arguments.empty?
            add_offense(node, message: format(FREEZE_MESSAGE, replacement: preferred_freeze_replacement)) do |corrector|
              autocorrect_freeze(corrector, node, arguments)
            end
          else
            add_offense(node, message: FREEZE_WITH_ARGUMENTS_MESSAGE)
          end
        end

        def on_timecop_return(node, arguments)
          add_offense(node, message: format(RETURN_MESSAGE, replacement: preferred_return_replacement)) do |corrector|
            autocorrect_return(corrector, node, arguments)
          end
        end

        def on_timecop_scale(node, _arguments)
          add_offense(node, message: SCALE_MESSAGE)
        end

        def on_timecop_travel(node, _arguments)
          add_offense(node, message: TRAVEL_MESSAGE)
        end

        def autocorrect_freeze(corrector, node, arguments)
          return unless arguments.empty?

          corrector.replace(receiver_and_message_range(node), preferred_freeze_replacement)
        end

        def autocorrect_return(corrector, node, _arguments)
          return if given_block?(node)

          corrector.replace(receiver_and_message_range(node), preferred_return_replacement)
        end

        def given_block?(node)
          node.send_type? && node.parent && node.parent.block_type? && node.parent.send_node == node
        end

        def receiver_and_message_range(node)
          node.source_range.with(end_pos: node.location.selector.end_pos)
        end

        def preferred_freeze_replacement
          return 'travel_to(Time.now)' if target_rails_version < 5.2

          'freeze_time'
        end

        def preferred_return_replacement
          return 'travel_back' if target_rails_version < 6.0

          'unfreeze_time'
        end
      end
    end
  end
end
