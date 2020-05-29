# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks the definition of model associations to only allow
      # string values on the reflection option `class_name`, preventing
      # the accidental autoloading of other model constants.
      #
      # @example
      #   # bad
      #   has_many :accounts, class_name: Account
      #   has_many :accounts, class_name: Account.name
      #
      #   # good
      #   has_many :accounts, class_name: 'Account'
      #   has_many :children, class_name: self.name
      class ReflectionClassName < Cop
        MSG = 'Use a string value for `class_name`.'

        def_node_matcher :association_with_reflection, <<~PATTERN
          (send nil? {:has_many :has_one :belongs_to} _
            (hash <$#reflection_class_name ...>)
          )
        PATTERN

        def_node_matcher :reflection_class_name, <<~PATTERN
          (pair (sym :class_name) {const (send const ...)})
        PATTERN

        def on_send(node)
          association_with_reflection(node) do |reflection_class_name|
            add_offense(node, location: reflection_class_name.loc.expression)
          end
        end
      end
    end
  end
end
