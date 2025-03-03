# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces consistent ordering of the standard Rails RESTful controller actions.
      #
      # The cop is configurable and can enforce any ordering of the standard actions.
      # All other methods are ignored. So, the actions specified in `ExpectedOrder` should be
      # defined before actions not specified.
      #
      # [source,yaml]
      # ----
      #  Rails/ActionOrder:
      #    ExpectedOrder:
      #      - index
      #      - show
      #      - new
      #      - edit
      #      - create
      #      - update
      #      - destroy
      # ----
      #
      # @example
      #   # bad
      #   def index; end
      #   def destroy; end
      #   def show; end
      #
      #   # good
      #   def index; end
      #   def show; end
      #   def destroy; end
      #
      # @example
      #   # bad
      #   resources :books, only: [:show, :index]
      #   resources :books, except: [:update, :edit]
      #
      #   # good
      #   resources :books, only: [:index, :show]
      #   resources :books, except: [:edit, :update]
      class ActionOrder < Base
        extend AutoCorrector
        include VisibilityHelp
        include DefNode
        include RangeHelp

        RESTRICT_ON_SEND = %i[resource resources].freeze

        MSG = 'Action `%<current>s` should appear before `%<previous>s`.'

        def_node_search :action_declarations, '(def {%1} ...)'

        def_node_matcher :resource, <<~PATTERN
          (send nil? {:resource :resources} _ $(hash <(pair (sym {:only :except}) (array ...)) ...>))
        PATTERN

        def_node_search :resource_argument, <<~PATTERN
          (pair (sym {:only :except}) $(array ...))
        PATTERN

        def_node_search :resource_action_value, <<~PATTERN
          $(sym ...)
        PATTERN

        def on_class(node)
          action_declarations(node, actions).each_cons(2) do |previous, current|
            next if node_visibility(current) != :public || non_public?(current)
            next if find_index(current) >= find_index(previous)

            register_offense(previous, current)
          end
        end

        def on_send(node)
          resource(node) do |hash_node|
            resource_argument(hash_node) do |array_node|
              resource_action_value(array_node).each_cons(2) do |previous, current|
                register_offense(previous, current) if find_index(current) < find_index(previous)
              end
            end
          end
        end

        private

        def expected_order
          cop_config['ExpectedOrder'].map(&:to_sym)
        end

        def actions
          @actions ||= Set.new(expected_order)
        end

        def action_name(node)
          if node.is_a?(RuboCop::AST::DefNode)
            node.method_name
          else
            node.value
          end
        end

        def find_index(node)
          expected_order.find_index(action_name(node))
        end

        def register_offense(previous, current)
          message = format(
            MSG,
            expected_order: expected_order.join(', '),
            previous: action_name(previous),
            current: action_name(current)
          )
          add_offense(current, message: message) do |corrector|
            current = correction_target(current)
            previous = correction_target(previous)

            swap_range(corrector, current, previous)
          end
        end

        def correction_target(def_node)
          range_with_comments_and_lines(def_node.each_ancestor(:if).first || def_node)
        end

        def add_range(range1, range2)
          range1.with(
            begin_pos: [range1.begin_pos, range2.begin_pos].min,
            end_pos: [range1.end_pos, range2.end_pos].max
          )
        end

        def range_with_comments(node)
          ranges = [node, *processed_source.ast_with_comments[node]].map(&:source_range)
          ranges.reduce do |result, range|
            add_range(result, range)
          end
        end

        def range_with_comments_and_lines(node)
          range_by_whole_lines(range_with_comments(node), include_final_newline: true)
        end

        def swap_range(corrector, range1, range2)
          corrector.insert_before(range2, range1.source)
          corrector.remove(range1)
        end
      end
    end
  end
end
