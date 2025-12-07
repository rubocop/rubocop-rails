# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Prefer `response.parsed_body` to custom parsing logic for `response.body`.
      #
      # @safety
      #   This cop is unsafe because Content-Type may not be `application/json` or `text/html`.
      #   For example, the proprietary Content-Type provided by corporate entities such as
      #   `application/vnd.github+json` is not supported at `response.parsed_body` by default,
      #   so you still have to use `JSON.parse(response.body)` there.
      #
      # @example
      #   # bad
      #   JSON.parse(response.body)
      #   Nokogiri::HTML(response.body)
      #   Nokogiri::HTML4(response.body)
      #   Nokogiri::HTML5(response.body)
      #   Nokogiri::HTML.parse(response.body)
      #   Nokogiri::HTML4.parse(response.body)
      #   Nokogiri::HTML5.parse(response.body)
      #   Nokogiri::HTML::Document.parse(response.body)
      #   Nokogiri::HTML4::Document.parse(response.body)
      #   Nokogiri::HTML5::Document.parse(response.body)
      #
      #   # good
      #   response.parsed_body
      class ResponseParsedBody < Base
        extend AutoCorrector
        extend TargetRailsVersion

        MSG = 'Prefer `response.parsed_body`.'

        HTML = %i[HTML HTML4 HTML5].to_set.freeze

        RESTRICT_ON_SEND = [:parse, *HTML].freeze

        minimum_target_rails_version 5.0

        # @!method json_parse_response_body?(node)
        def_node_matcher :json_parse_response_body?, <<~PATTERN
          (send #json? :parse #response_body?)
        PATTERN

        # @!method nokogiri_html_response_body?(node)
        def_node_matcher :nokogiri_html_response_body?, <<~PATTERN
          (send #nokogiri? HTML #response_body?)
        PATTERN

        # @!method nokogiri_html_parse_response_body?(node)
        def_node_matcher :nokogiri_html_parse_response_body?, <<~PATTERN
          (send #nokogiri_html? :parse #response_body?)
        PATTERN

        # @!method nokogiri_html_document_parse_response_body?(node)
        def_node_matcher :nokogiri_html_document_parse_response_body?, <<~PATTERN
          (send (const #nokogiri_html? :Document) :parse #response_body?)
        PATTERN

        # @!method json?(node)
        def_node_matcher :json?, <<~PATTERN
          (const {nil? cbase} :JSON)
        PATTERN

        # @!method nokogiri?(node)
        def_node_matcher :nokogiri?, <<~PATTERN
          (const {nil? cbase} :Nokogiri)
        PATTERN

        # @!method nokogiri_html?(node)
        def_node_matcher :nokogiri_html?, <<~PATTERN
          (const #nokogiri? HTML)
        PATTERN

        # @!method response_body?(node)
        def_node_matcher :response_body?, <<~PATTERN
          (send (send nil? :response) :body)
        PATTERN

        def on_send(node)
          return unless html_offense?(node) || json_offense?(node)

          add_offense(node) do |corrector|
            corrector.replace(node, 'response.parsed_body')
          end
        end

        private

        def html_offense?(node)
          support_response_parsed_body_for_html? &&
            (nokogiri_html_response_body?(node) ||
              nokogiri_html_parse_response_body?(node) ||
              nokogiri_html_document_parse_response_body?(node))
        end

        def json_offense?(node)
          json_parse_response_body?(node)
        end

        def support_response_parsed_body_for_html?
          target_rails_version >= 7.1
        end
      end
    end
  end
end
