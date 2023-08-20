# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks that instance variables are not used in instances of `ActiveSupport::CurrentAttributes`.
      #
      # Using instance variables in `CurrentAttributes` can lead to data being shared across requests.
      # Use the managed `attribute` state instead.
      #
      # @example
      #   # bad
      #   class Current < ActiveSupport::CurrentAttributes
      #     attribute :user
      #
      #     def account
      #       @account ||= user.account
      #     end
      #   end
      #
      #   # good
      #   class Current < ActiveSupport::CurrentAttributes
      #     attribute :account, :user
      #
      #     def user=(user)
      #       super
      #       self.account = user.account
      #     end
      #   end
      class CurrentAttributesInstanceVariable < Base
        MSG = 'Do not use instance variables in instances of CurrentAttributes.'

        def_node_matcher :current_attributes_class?, <<~PATTERN
          (const
            (const {nil? cbase} :ActiveSupport) :CurrentAttributes)
        PATTERN

        def on_ivar(node)
          return unless inherit_current_attributes?(node)

          add_offense(node)
        end

        def on_ivasgn(node)
          return unless inherit_current_attributes?(node)

          add_offense(node.loc.name)
        end

        private

        def inherit_current_attributes?(node)
          node.each_ancestor(:class).any? { |class_node| current_attributes_class?(class_node.parent_class) }
        end
      end
    end
  end
end
