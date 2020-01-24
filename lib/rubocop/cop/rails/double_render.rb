# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks reachable render methods (i.e `render` `redirect_to`)
      # are not multiple.
      #
      # @example
      #   #bad
      #   def show
      #     render :some_view
      #     if cond?
      #        redirect_to :index
      #     end
      #   end
      #
      class DoubleRender < Cop
        MSG = 'AbstractController::DoubleRenderError may occur.'
        RENDER_METHODS = %i[render redirect_to].freeze

        def on_def(node)
          reachable_render_method_nodes = select_reachable(node.body)

          return unless reachable_render_method_nodes.size > 1

          reachable_render_method_nodes.flatten.each do |render_method_node|
            add_offense(render_method_node, location: :selector)
          end
        end

        private

        def select_reachable(node)
          render_method_nodes = []

          case node&.type
          when :send
            render_method_nodes.push([node]) if render_method_node?(node)
          when :if
            render_method_nodes.push(select_if_reachable(node))
          when :case
            render_method_nodes.push(select_case_reachable(node))
          else
            node&.each_child_node&.each do |child_node|
              render_method_nodes.push(select_reachable(child_node))
            end
          end

          render_method_nodes.select(&:any?)
        end

        def select_if_reachable(if_node)
          if_reachable = select_reachable(if_node.if_branch)
          else_reachable = select_reachable(if_node.else_branch)

          [if_reachable, else_reachable].select(&:any?)
        end

        def select_case_reachable(case_node)
          when_reachable =
            case_node.when_branches
                     .map { |branch| select_reachable(branch) }
                     .select(&:any?)
          else_reachable = select_reachable(case_node.else_branch)

          [when_reachable, else_reachable].select(&:any?)
        end

        def render_method_node?(node)
          RENDER_METHODS.include?(node.method_name)
        end
      end
    end
  end
end
