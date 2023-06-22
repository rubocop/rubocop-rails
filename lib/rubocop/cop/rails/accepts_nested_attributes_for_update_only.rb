# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Looks for `accepts_nested_attributes_for` attributes writers that don't
      # specify an `:update_only` option.
      #
      # @example
      #   # bad
      #   class Member < ActiveRecord::Base
      #     has_one :avatar
      #     accepts_nested_attributes_for :avatar
      #   end
      #
      #   # good
      #   class Member < ActiveRecord::Base
      #     has_one :avatar
      #     accepts_nested_attributes_for :avatar, update_only: true
      #   end
      class AcceptsNestedAttributesForUpdateOnly < Base
        MSG = 'Specify a `:update_only` option.'
        RESTRICT_ON_SEND = %i[accepts_nested_attributes_for].freeze

        def_node_search :active_resource_class?, <<~PATTERN
          (const (const {nil? cbase} :ActiveResource) :Base)
        PATTERN

        def_node_matcher :accepts_nested_attributes_for_without_options?, <<~PATTERN
          (send _ {:accepts_nested_attributes_for} _)
        PATTERN

        def_node_matcher :accepts_nested_attributes_for_with_options?, <<~PATTERN
          (send _ {:accepts_nested_attributes_for} ... (hash $...))
        PATTERN

        def_node_matcher :update_only_option?, <<~PATTERN
          (pair (sym :update_only) {!nil (nil)})
        PATTERN

        def_node_matcher :with_options_block, <<~PATTERN
          (block
            (send nil? :with_options
              (hash $...))
            (args) ...)
        PATTERN

        def_node_matcher :accepts_nested_attributes_for_extension_block?, <<~PATTERN
          (block
            (send nil? :accepts_nested_attributes_for _)
            (args) ...)
        PATTERN

        def on_send(node)
          return if active_resource?(node.parent)
          return if !accepts_nested_attributes_for_without_options?(node) && \
                    valid_options?(accepts_nested_attributes_for_with_options?(node))
          return if valid_options_in_with_options_block?(node)

          add_offense(node.loc.selector)
        end

        private

        def valid_options_in_with_options_block?(node)
          return true unless node.parent

          n = node.parent.begin_type?
          n ||= accepts_nested_attributes_for_extension_block?(node.parent) ? node.parent.parent : node.parent

          contain_valid_options_in_with_options_block?(n)
        end

        def contain_valid_options_in_with_options_block?(node)
          if (options = with_options_block(node))
            return true if valid_options?(options)

            return false unless node.parent

            return true if contain_valid_options_in_with_options_block?(node.parent.parent)
          end

          false
        end

        def valid_options?(options)
          return false if options.nil?

          options = extract_option_if_kwsplat(options)

          return true unless options
          return true if options.any? do |o|
            update_only_option?(o)
          end

          false
        end

        def extract_option_if_kwsplat(options)
          if options.first.kwsplat_type? && options.first.children.first.hash_type?
            return options.first.children.first.pairs
          end

          options
        end

        def active_resource?(node)
          return false if node.nil?

          active_resource_class?(node)
        end
      end
    end
  end
end
