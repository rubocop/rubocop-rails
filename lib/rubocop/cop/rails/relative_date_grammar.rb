# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks whether the word orders of relative dates are grammatically easy to understand.
      # This check includes detecting undefined methods on Date(Time) objects.
      #
      # @safety
      #   This cop is unsafe because it avoids strict checking of receivers' types,
      #   ActiveSupport::Duration and Date(Time) respectively.
      #
      # @example
      #   # bad
      #   tomorrow = Time.current.since(1.day)
      #
      #   # good
      #   tomorrow = 1.day.since(Time.current)
      class RelativeDateGrammar < Base
        extend AutoCorrector

        MSG = 'Use ActiveSupport::Duration#%<relation>s as a receiver ' \
              'for relative date like `%<duration>s.%<relation>s(%<date>s)`.'

        RELATIVE_DATE_METHODS = %i[since from_now after ago until before].to_set.freeze
        DURATION_METHODS = %i[second seconds minute minutes hour hours
                              day days week weeks month months year years].to_set.freeze

        RESTRICT_ON_SEND = RELATIVE_DATE_METHODS.to_a.freeze

        def_node_matcher :inverted_relative_date?, <<~PATTERN
          (send
            $!nil?
            $RELATIVE_DATE_METHODS
            $(send
              !nil?
              $DURATION_METHODS
            )
          )
        PATTERN

        def on_send(node)
          inverted_relative_date?(node) do |date, relation, duration|
            message = format(MSG, date: date.source, relation: relation.to_s, duration: duration.source)
            add_offense(node, message: message) do |corrector|
              autocorrect(corrector, node, date, relation, duration)
            end
          end
        end

        private

        def autocorrect(corrector, node, date, relation, duration)
          new_code = ["#{duration.source}.#{relation}(#{date.source})"]
          corrector.replace(node, new_code)
        end
      end
    end
  end
end
