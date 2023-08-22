# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks the usage of singular and plural method forms for
      # `year`, `week`, `month`, `day`, `hour`, `minute`, and `second`.
      #
      # @example
      #
      #   # bad
      #   1.hours
      #   42.minute
      #
      #   # good
      #   1.hour
      #   42.minutes
      #
      class TimeUnitNumberForm < Base
        extend AutoCorrector

        MSG = 'Use `%<preferred_method>s`.'

        RESTRICT_ON_SEND = %i[
          year years month months week weeks day days hour hours minute minutes second seconds
        ].freeze

        PLURALS = {
          year: :years,
          month: :months,
          week: :weeks,
          day: :days,
          hour: :hours,
          minute: :minutes,
          second: :seconds
        }.freeze

        SINGULARS = PLURALS.invert.freeze

        def on_send(node)
          return unless node.receiver.int_type?

          method_name = node.method_name
          preferred_method = node.receiver.source == '1' ? SINGULARS[method_name] : PLURALS[method_name]
          return unless preferred_method

          range = node.loc.selector
          message = format(MSG, preferred_method: preferred_method)

          add_offense(range, message: message) do |corrector|
            corrector.replace(range, preferred_method)
          end
        end
      end
    end
  end
end
