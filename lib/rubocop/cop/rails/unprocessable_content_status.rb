# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces the use of :unprocessable_content instead of :unprocessable_entity
      # for HTTP status codes, as :unprocessable_entity is deprecated in Rack 3.1.
      #
      # @example
      #   # bad
      #   render json: { error: "Invalid data" }, status: :unprocessable_entity
      #   head :unprocessable_entity
      #
      #   # good
      #   render json: { error: "Invalid data" }, status: :unprocessable_content
      #   head :unprocessable_content
      #
      class UnprocessableContentStatus < Base
        extend AutoCorrector

        MSG = 'Use `:unprocessable_content` instead of `:unprocessable_entity`. ' \
              'The `:unprocessable_entity` status is deprecated.'

        def_node_matcher :unprocessable_entity_symbol?, <<~PATTERN
          (sym :unprocessable_entity)
        PATTERN

        def_node_matcher :status_argument?, <<~PATTERN
          (pair (sym :status) (sym :unprocessable_entity))
        PATTERN

        def on_sym(node)
          return unless rack_3_1_or_newer?

          return unless unprocessable_entity_symbol?(node)
          return if in_hash_key_context?(node)

          return unless status_related_context?(node)

          add_offense(node) do |corrector|
            corrector.replace(node, ':unprocessable_content')
          end
        end

        def on_pair(node)
          return unless rack_3_1_or_newer?

          status_argument?(node) do
            add_offense(node.value) do |corrector|
              corrector.replace(node.value, ':unprocessable_content')
            end
          end
        end

        private

        def rack_3_1_or_newer?
          Gem::Version.new(Rack::VERSION) >= Gem::Version.new('3.1.0')
        rescue ArgumentError, NoMethodError
          false
        end

        def in_hash_key_context?(node)
          node.parent&.pair_type? && node.parent.key == node
        end

        def status_related_context?(node)
          parent = node.parent
          return false unless parent

          if parent.send_type?
            method_name = parent.method_name
            return %i[head render redirect_to].include?(method_name)
          end

          # Variable assignment or ternary expression
          %i[lvasgn if].include?(parent.type)
        end
      end
    end
  end
end
