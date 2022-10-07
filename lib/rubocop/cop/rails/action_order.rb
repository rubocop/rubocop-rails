# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces consistent ordering of the standard Rails RESTful controller actions.
      #
      # The cop is configurable and can enforce any ordering of the standard actions.
      # All other methods are ignored.
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
      class ActionOrder < Base
        extend AutoCorrector
        include VisibilityHelp
        include DefNode

        MSG = 'Action `%<current>s` should appear before `%<previous>s`.'

        def_node_search :action_declarations, '(def {%1} ...)'

        def on_class(node)
          action_declarations(node, actions).each_cons(2) do |previous, current|
            next if node_visibility(current) != :public || non_public?(current)
            next if find_index(current) >= find_index(previous)

            register_offense(previous, current)
          end
        end

        private

        def expected_order
          cop_config['ExpectedOrder'].map(&:to_sym)
        end

        def actions
          @actions ||= Set.new(expected_order)
        end

        def find_index(node)
          expected_order.find_index(node.method_name)
        end

        def register_offense(previous, current)
          message = format(
            MSG,
            expected_order: expected_order.join(', '),
            previous: previous.method_name,
            current: current.method_name
          )
          add_offense(current, message: message) do |corrector|
            corrector.replace(current, previous.source)
            corrector.replace(previous, current.source)
          end
        end
      end
    end
  end
end
