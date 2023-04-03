# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Prefer `response.parsed_body` to `JSON.parse(response.body)`.
      #
      # @safety
      #   This cop is unsafe because Content-Type may not be `application/json`. For example, the proprietary
      #   Content-Type provided by corporate entities such as `application/vnd.github+json` is not supported at
      #   `response.parsed_body` by default, so you still have to use `JSON.parse(response.body)` there.
      #
      # @example
      #   # bad
      #   JSON.parse(response.body)
      #
      #   # good
      #   response.parsed_body
      class ResponseParsedBody < Base
        extend AutoCorrector
        extend TargetRailsVersion

        MSG = 'Prefer `response.parsed_body` to `JSON.parse(response.body)`.'

        RESTRICT_ON_SEND = %i[parse].freeze

        minimum_target_rails_version 5.0

        # @!method json_parse_response_body?(node)
        def_node_matcher :json_parse_response_body?, <<~PATTERN
          (send
            (const {nil? cbase} :JSON)
            :parse
            (send
              (send nil? :response)
              :body
            )
          )
        PATTERN

        def on_send(node)
          return unless json_parse_response_body?(node)

          add_offense(node) do |corrector|
            autocorrect(corrector, node)
          end
        end

        private

        def autocorrect(corrector, node)
          corrector.replace(node, 'response.parsed_body')
        end
      end
    end
  end
end
