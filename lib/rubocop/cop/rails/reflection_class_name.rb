# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks if the value of the option `class_name`, in
      # the definition of a reflection is a string.
      #
      # @example
      #   # bad
      #   has_many :accounts, class_name: Account
      #   has_many :accounts, class_name: Account.name
      #
      #   # good
      #   has_many :accounts, class_name: 'Account'
      class ReflectionClassName < Base
        extend AutoCorrector

        MSG = 'Use a string value for `class_name`.'
        RESTRICT_ON_SEND = %i[has_many has_one belongs_to].freeze

        def_node_matcher :association_with_reflection, <<~PATTERN
          (send nil? {:has_many :has_one :belongs_to} _ _ ?
            (hash <$#reflection_class_name ...>)
          )
        PATTERN

        def_node_matcher :reflection_class_name, <<~PATTERN
          (pair (sym :class_name) $[!dstr !str !sym])
        PATTERN

        def on_send(node)
          association_with_reflection(node) do |reflection|
            add_offense(reflection) do |corrector|
              class_node = reflection_class_name(reflection)
              corrector.replace(class_node, replacement(class_node))
            end
          end
        end

        private

        def replacement(class_node)
          replacement_node = class_node.send_type? ? class_node.children.first : class_node
          replacement_node.source.inspect
        end
      end
    end
  end
end
