# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop suggests extracting custom validator classes from format validations.
      #
      # @example
      #   # bad
      #   class User < ApplicationRecord
      #     validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
      #   end
      #
      #   # good
      #   class EmailValidator < ActiveModel::EachValidator
      #     def validate_each(record, attribute, value)
      #       unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      #         record.errors[attribute] << (options[:message] || 'is not a valid email')
      #       end
      #     end
      #   end
      #
      #   class User < ApplicationRecord
      #     validates :email, email: true
      #   end
      #
      class CustomValidator < Cop
        MSG = 'Consider extracting custom validator.'

        def_node_matcher :validates_format?, <<~PATTERN
          (send nil? :validates ...
            (hash
              <(pair (sym :format) _) ...>))
        PATTERN

        def on_send(node)
          add_offense(node) if validates_format?(node)
        end
      end
    end
  end
end
