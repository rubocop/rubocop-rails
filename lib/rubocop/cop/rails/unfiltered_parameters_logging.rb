# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for unfiltered request parameters in log messages.
      # Use `request.filtered_parameters` to apply configured parameter filtering.
      #
      # Explicit field selection is allowed, but does not redact the selected values.
      # A selected field may itself contain a nested hash or sensitive data.
      #
      # @safety
      #   This cop assumes `params`, `request`, and `logger` refer to Rails APIs.
      #   It does not follow local variable aliases or recognize custom filtering methods.
      #
      #   Intermediate parameter references in message blocks may be flagged even when
      #   the block's final value does not expose them.
      #
      # @example
      #   # bad
      #   Rails.logger.info(params)
      #   logger.debug { request.parameters.to_json }
      #
      #   # good
      #   Rails.logger.info(request.filtered_parameters)
      #   logger.info(params.slice(:id))
      #   logger.info(params.size)
      class UnfilteredParametersLogging < Base
        MSG = 'Avoid logging unfiltered parameters. ' \
              'Use `request.filtered_parameters` for configured filtering, or select reviewed fields.'
        RESTRICT_ON_SEND = %i[debug info warn error fatal unknown add log].freeze

        SELECTION_METHODS = %i[slice permit expect expect! fetch dig []].freeze
        SUMMARY_METHODS = %i[size length bytesize count keys].freeze

        def_node_matcher :logger?, <<~PATTERN
          {
            (call {nil? self (const {nil? cbase} :Rails)} :logger)
            (call #logger? :tagged ...)
          }
        PATTERN

        def_node_matcher :parameters?, <<~PATTERN
          {
            (call {nil? self} :params)
            (call (call {nil? self} :request) {:params :parameters})
          }
        PATTERN

        def on_send(node)
          return unless logger?(node.receiver)

          node.arguments.each { |argument| check_parameters(argument) }

          block = node.parent
          check_parameters(block.body) if block&.any_block_type? && block.send_node == node
        end
        alias on_csend on_send

        private

        def check_parameters(expression)
          return unless expression

          expression.each_node(:call) do |node|
            next unless parameters?(node)
            next if selected_parameters?(node) || summarized_parameters?(node)

            add_offense(node)
          end
        end

        def selected_parameters?(node)
          return false unless (parent = receiver_parent(node))

          if parent.method?(:require)
            selected_parameters?(parent)
          else
            SELECTION_METHODS.include?(parent.method_name)
          end
        end

        def summarized_parameters?(node)
          while (parent = receiver_parent(node))
            return true if parent.predicate_method? || SUMMARY_METHODS.include?(parent.method_name)

            node = parent
          end

          false
        end

        def receiver_parent(node)
          parent = node.parent
          if parent&.any_block_type? && parent.send_node.equal?(node)
            node = parent
            parent = node.parent
          end

          parent if parent&.call_type? && parent.receiver.equal?(node)
        end
      end
    end
  end
end
