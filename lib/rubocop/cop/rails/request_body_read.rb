# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # `request.body.read` is a Rack API. It is unstable from Rails' perspective.
      # Starting in Rack 3, it consumes the stream and requires manual rewinding
      # to read twice, which is a common source of bugs.
      # `request.raw_post` is a Rails API. It does memoization andautomatically
      # handles rewinding, avoiding the associated bugs.
      #
      # @safety
      #   This cop's autocorrection is unsafe because you might _intentionally_ be
      #   using the lower-level tool `request.body.read`.
      #
      # @example
      #   # bad
      #   request.body.read
      #
      #   # good
      #   request.raw_post
      #
      #   # good (partial read)
      #   request.body.read(16.kilobytes)
      #
      class RequestBodyRead < Base
        extend AutoCorrector
        extend TargetRailsVersion

        MSG = 'Use `request.raw_post` instead.'

        minimum_target_rails_version 3.0

        def_node_matcher :request_body_read?, <<~PATTERN
          (send
            (send
              (send nil? :request) :body) :read)
        PATTERN

        def on_send(node)
          return unless request_body_read?(node)

          add_offense(node) do |corrector|
            corrector.replace(node, 'request.raw_post')
          end
        end
      end
    end
  end
end
