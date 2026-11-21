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
      class ActionControllerFlashBeforeRender < Base # rubocop:disable Metrics/ClassLength
        extend AutoCorrector

        MSG = 'Use `flash.now` before `render`.'

        def_node_search :flash_assignment?, <<~PATTERN
          ^(send (send nil? :flash) :[]= ...)
        PATTERN

        def_node_matcher :render_call?, <<~PATTERN
          (send nil? :render ...)
        PATTERN

        def_node_matcher :rollback?, <<~PATTERN
          (send nil? {:raise :fail} {#rollback_class? (send #rollback_class? :new ...)} ...)
        PATTERN

        def_node_matcher :rollback_class?, <<~PATTERN
          (const (const {nil? cbase} :ActiveRecord) :Rollback)
        PATTERN

        def_node_search :action_controller?, <<~PATTERN
          {
            (const {nil? cbase} :ApplicationController)
            (const (const {nil? cbase} :ActionController) :Base)
          }
        PATTERN

        RESTRICT_ON_SEND = [:flash].freeze
        REDIRECT_METHODS = %i[redirect_to redirect_back redirect_back_or_to].freeze
        LOOP_TYPES = %i[while until for while_post until_post].freeze
        RESPONSES = %i[render redirect].freeze
        FINAL_RESPONSES = [*RESPONSES, :exited].freeze

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
          flash_assignment_node = find_ancestor(flash_node, type: :send)
          path = execution_path(flash_assignment_node)
          response = response_on(path)
          return response == :render if response

          implicit_render?(flash_assignment_node, path)
        end

        def execution_path(node)
          [node, *node.each_ancestor.take_while { |ancestor| !ancestor.type?(:any_def, :class, :module, :sclass) }]
        end

        def response_on(path)
          index = 0
          iterating = true

          while (context = path[index])
            return :render if iterating && render_in_next_iteration?(context, path.first)

            response = first_response_after(context)
            return response if FINAL_RESPONSES.include?(response)

            next_index = response ? jump_target(path, index, response) : index + 1
            ensure_response = response_in_ensure_branches(path[(index + 1)...next_index])
            return ensure_response if ensure_response

            iterating = response != :break
            index = next_index
          end
        end

        def render_in_next_iteration?(node, flash_assignment_node)
          return false unless node.type?(*LOOP_TYPES) && node.body

          statements = node.body.type?(:begin, :kwbegin) ? node.body.children : [node.body]
          statements = statements.reject { |statement| respond_to_containing?(statement, flash_assignment_node) }

          first_response_in(statements) == :render
        end

        def respond_to_containing?(statement, node)
          statement.any_block_type? && statement.method?(:respond_to) &&
            statement.each_descendant.any? { |descendant| descendant.equal?(node) }
        end

        def first_response_in(statements)
          statements.each_with_index do |statement, index|
            response = response_of(statement, statements.drop(index))

            return response if response
          end

          nil
        end

        def response_of(statement, remaining_statements)
          if (format_blocks = format_alternatives(statement, remaining_statements))
            return formats_response(format_blocks)
          end
          if (statements = normal_flow_sequence(statement))
            return first_response_in(statements)
          end
          return :redirect if redirect?(statement)
          return :render if render?(statement)

          jump_of(statement)
        end

        def format_alternatives(statement, remaining_statements)
          return [statement] if statement.any_block_type? && statement.method?(:respond_to)
          return unless respond_to_format_block?(statement)

          remaining_statements.select { |format| respond_to_format_block?(format) }
        end

        def respond_to_format_block?(node)
          return false unless node.any_block_type?

          format = node.receiver
          respond_to_block = node.each_ancestor(:any_block).first
          return false unless format&.lvar_type? && respond_to_block&.method?(:respond_to)

          format.children.first == block_parameter_name(respond_to_block)
        end

        def block_parameter_name(block_node)
          return :_1 if block_node.numblock_type?
          return :it if block_node.type?(:itblock)

          argument = block_node.first_argument
          argument.name if argument&.arg_type?
        end

        def formats_response(format_blocks)
          return :redirect if format_blocks.any? { |format| contains_redirect?(format) }

          :render if format_blocks.any? { |format| render?(format) }
        end

        def contains_redirect?(node)
          node.each_node(:send).any? { |send_node| redirect?(send_node) }
        end

        def render?(node)
          return true if render_call?(node)
          return false if node.type?(:resbody, :any_def)

          if (statements = normal_flow_sequence(node))
            return first_response_in(statements) == :render
          end

          node.children.grep(AST::Node).any? { |child| render?(child) }
        end

        def normal_flow_sequence(node)
          if node.type?(:begin, :kwbegin)
            node.children
          elsif node.rescue_type?
            [node.body, node.else_branch].compact
          end
        end

        def raise?(node)
          node.send_type? && node.receiver.nil? && %i[raise fail].include?(node.method_name)
        end

        def jump_of(statement)
          return :rollback if rollback?(statement) && in_transaction?(statement)
          return :exited if raise?(statement)

          statement.type if statement.type?(:return, :next, :break)
        end

        def in_transaction?(node)
          node.each_ancestor(:any_block, :any_def).find do |ancestor|
            ancestor.any_def_type? || ancestor.method?(:transaction)
          end&.any_block_type?
        end

        def first_response_after(node)
          first_response_in(following_siblings(node))
        end

        def following_siblings(node)
          return [] if node.resbody_type? || respond_to_format_block?(node)

          parent = node.parent
          return [] if parent&.type?(:if, :case, :case_match) && !parent.children.first.equal?(node)

          node.right_siblings.grep(AST::Node)
        end

        def jump_target(path, index, response)
          return path.size if response == :return

          ((index + 1)...path.size).find { |target_index| jump_destination?(path[target_index], response) } || path.size
        end

        def jump_destination?(node, response)
          return node.any_block_type? && node.method?(:transaction) if response == :rollback

          node.type?(:any_block, *LOOP_TYPES)
        end

        def response_in_ensure_branches(contexts)
          contexts.each do |context|
            next unless ensure_body?(context)

            response = first_response_after(context)
            return response if RESPONSES.include?(response)
          end

          nil
        end

        def ensure_body?(node)
          parent = node.parent
          parent&.ensure_type? && parent.children.first.equal?(node)
        end

        def implicit_render?(flash_assignment_node, path)
          return false if flash_assignment_node.parent.nil? || in_branch?(flash_assignment_node)
          return false unless flash_assignment_node.right_siblings.empty?

          path.none? { |context| redirect_around?(context) }
        end

        def redirect_around?(node)
          return true if node.left_siblings.grep(AST::Node).any? { |statement| redirect?(statement) }

          following_siblings(node).any? { |statement| !statement.any_def_type? && contains_redirect?(statement) }
        end

        def in_branch?(node)
          node.each_ancestor(:if, :case, :case_match, :rescue, :any_def).first&.type?(:if, :case, :case_match, :rescue)
        end

        def inherit_action_controller_base?(node)
          class_node = find_ancestor(node, type: :class)
          return false unless class_node

          action_controller?(class_node)
        end

        def instance_method_or_block?(node)
          def_node = find_ancestor(node, type: :def)
          block_node = find_ancestor(node, type: :block)

          def_node || block_node
        end

        def redirect?(node)
          node = node.children.first if node.return_type? && node.children.one?
          node = node.lhs if node.and_type?

          node.send_type? && REDIRECT_METHODS.include?(node.method_name)
        end

        def find_ancestor(node, type:)
          node.each_ancestor(type).first
        end
      end
    end
  end
end
