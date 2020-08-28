# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for `attribute` class methods that specify a `:default` option
      # which value is a method call without a block.
      # It will accept all other values, such as literals and constants.
      #
      # @example
      #   # bad
      #   class User < ApplicationRecord
      #     attribute :confirmed_at, :datetime, default: Time.zone.now
      #   end
      #
      #   # good
      #   class User < ActiveRecord::Base
      #     attribute :confirmed_at, :datetime, default: -> { Time.zone.now }
      #   end
      #
      #   # good
      #   class User < ActiveRecord::Base
      #     attribute :role, :string, default: :customer
      #   end
      #
      #   # good
      #   class User < ActiveRecord::Base
      #     attribute :activated, :boolean, default: false
      #   end
      #
      #   # good
      #   class User < ActiveRecord::Base
      #     attribute :login_count, :integer, default: 0
      #   end
      #
      #   # good
      #   class User < ActiveRecord::Base
      #     FOO = 123
      #     attribute :custom_attribute, :integer, default: FOO
      #   end
      class AttributeDefaultBlockValue < Cop
        MSG = 'Pass method in a block to `:default` option.'

        def_node_matcher :default_attribute, <<~PATTERN
          (send nil? :attribute _ _ (hash <$#attribute ...>))
        PATTERN

        def_node_matcher :attribute, '(pair (sym :default) $_)'

        def on_send(node)
          default_attribute(node) do |attribute|
            value = attribute.children.last

            add_offense(node, location: value) if value.send_type?
          end
        end

        def autocorrect(node)
          expression = default_attribute(node).children.last

          lambda do |corrector|
            corrector.replace(expression, "-> { #{expression.source} }")
          end
        end
      end
    end
  end
end
