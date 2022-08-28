# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Using `flash` assignment before `render` in Rails controllers will persist the message for too long.
      # Check https://guides.rubyonrails.org/action_controller_overview.html#flash-now
      #
      # @safety
      #   This cop's autocorrection is unsafe because it replaces `flash` by `flash.now`.
      #   Even though it is usually a mistake, it might be used intentionally.
      #
      # @example
      #
      #   # bad
      #   class HomeController < ApplicationController
      #     def create
      #       flash[:alert] = "msg"
      #       render :index
      #     end
      #   end
      #
      #   # good
      #   class HomeController < ApplicationController
      #     def create
      #       flash.now[:alert] = "msg"
      #       render :index
      #     end
      #   end
      #
      class ActionControllerFlashBeforeRender < Base
        extend AutoCorrector

        MSG = 'Use `flash.now` before `render`.'

        def_node_search :flash_assignment?, <<~PATTERN
          ^(send (send nil? :flash) :[]= ...)
        PATTERN

        def_node_search :render?, <<~PATTERN
          (send nil? :render ...)
        PATTERN

        def_node_search :action_controller?, <<~PATTERN
          {
            (const nil? :ApplicationController)
            (const (const nil? :ActionController) :Base)
          }
        PATTERN

        RESTRICT_ON_SEND = [:flash].freeze

        def on_send(flash_node)
          return unless flash_assignment?(flash_node)

          return unless followed_by_render?(flash_node)

          return unless instance_method_or_block?(flash_node)

          return unless inherit_action_controller_base?(flash_node)

          add_offense(flash_node) do |corrector|
            corrector.replace(flash_node, 'flash.now')
          end
        end

        private

        def followed_by_render?(flash_node)
          flash_assigment_node = find_ancestor(flash_node, type: :send)
          context = flash_assigment_node.parent

          context.each_child_node.any? do |node|
            render?(node)
          end
        end

        def inherit_action_controller_base?(node)
          class_node = find_ancestor(node, type: :class)
          return unless class_node

          action_controller?(class_node)
        end

        def instance_method_or_block?(node)
          def_node = find_ancestor(node, type: :def)
          block_node = find_ancestor(node, type: :block)

          def_node || block_node
        end

        def find_ancestor(node, type:)
          node.each_ancestor(type).first
        end
      end
    end
  end
end
