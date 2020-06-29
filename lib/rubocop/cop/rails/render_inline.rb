# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for inline rendering within controller actions.
      #
      # @example
      #   # bad
      #   class ProductsController < ApplicationController
      #     def index
      #       render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>", type: :erb
      #     end
      #   end
      #
      #   # good
      #   # app/views/products/index.html.erb
      #   # <% products.each do |p| %>
      #   #   <p><%= p.name %></p>
      #   # <% end %>
      #
      #   class ProductsController < ApplicationController
      #     def index
      #     end
      #   end
      #
      class RenderInline < Cop
        MSG = 'Prefer using a template over inline rendering.'

        def_node_matcher :render_with_options?, <<~PATTERN
          (send nil? :render $(hash ...))
        PATTERN

        def on_send(node)
          render_with_options?(node) do |options|
            add_offense(node) if includes_inline_key?(options)
          end
        end

        private

        def includes_inline_key?(node)
          node.keys.find { |key| key.value.to_sym == :inline }
        end
      end
    end
  end
end
