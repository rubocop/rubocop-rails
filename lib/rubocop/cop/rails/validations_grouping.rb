# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces the grouping of attribute validations.
      #
      # @example
      #   # bad
      #   validates :name, :email, :bio, presence: true
      #   validates :email, format: { with: /@/ }
      #
      #   # good
      #   validates :name, :bio, presence: true
      #   validates :email, presence: true, format: { with: /@/ }
      #
      #   # good
      #   validates :name, :email, :bio, presence: true, if: :some_condition?
      #   validates :email, format: { with: /@/ }
      #
      # @example SingleAttributeValidations: true
      #   # Enforces single attribute per validation.
      #
      #   # bad
      #   validates :name, :bio, presence: true
      #
      #   # good
      #   validates :name, presence: true
      #   validates :bio, presence: true
      #
      class ValidationsGrouping < Base
        MSG = 'Group together all %<attribute>s validations.'
        SINGLE_ATTRIBUTE_MSG = 'Specify single attribute per validation.'

        VALIDATION_KEYS = %w[acceptance confirmation comparison exclusion format inclusion
                             length numericality presence absence uniqueness].freeze

        RESTRICT_ON_SEND = %i[validates].freeze

        def_node_matcher :validates?, <<~PATTERN
          (send nil? :validates ${sym str} + hash)
        PATTERN

        def on_new_investigation
          # Hash is keyed by parent id and then by attribute name within it.
          @validations = Hash.new do |outer, parent|
            outer[parent] = Hash.new { |inner, attribute| inner[attribute] = [] }
          end
          @validations.compare_by_identity
        end

        def on_send(node)
          validates?(node) do |attribute_nodes|
            if attribute_nodes.size > 1 && cop_config['SingleAttributeValidations']
              add_offense(node, message: SINGLE_ATTRIBUTE_MSG)
            end

            check_for_same_attributes_validations(node, attribute_nodes)
          end
        end

        private

        def check_for_same_attributes_validations(validation_node, attribute_nodes)
          attribute_nodes.each do |attribute_node|
            parent_node = validation_node.parent
            attribute_name = attribute_node.value.to_s
            @validations[parent_node][attribute_name] << validation_node

            validation_nodes = @validations[parent_node][attribute_name]
            next unless validation_nodes.size > 1 && same_options?(validation_nodes)

            message = format(MSG, attribute: attribute_name)

            validation_nodes.each do |node|
              add_offense(attribute_node(node, attribute_name), message: message)
            end
          end
        end

        def same_options?(validation_nodes)
          options = validation_nodes.map do |node|
            option_node = node.last_argument
            option_node.pairs.to_h do |pair|
              [pair.key.source, pair.value.source]
            end
          end

          options = options.map { |o| extra_options(o) }
          options.all?(options.first)
        end

        def extra_options(options)
          options.except(*VALIDATION_KEYS)
        end

        def attribute_node(validation_node, attribute_name)
          validation_node.arguments[0..-2].find do |argument|
            argument.value.to_s == attribute_name.to_s
          end
        end
      end
    end
  end
end
