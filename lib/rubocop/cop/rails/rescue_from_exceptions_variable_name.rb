# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Ensures that rescued exception variables are named as expected.
      #
      # The `PreferredName` config option specifies the required name of the variable.
      # Its default is `e`, as referenced from `Naming/RescuedExceptionsVariableName`.
      #
      # @example PreferredName: e (default)
      #   # bad
      #   rescue_from MyException do |exception|
      #     # do something
      #   end
      #
      #   # bad
      #   rescue_from MyException do |_exception|
      #     # do something
      #   end
      #
      #   # bad
      #   rescue_from MyException { |exception| do_something(exception) }
      #
      #   # bad
      #   rescue_from MyException, with: ->(exception) do
      #     do_something(exception)
      #   end
      #
      #   # bad
      #   rescue_from MyException, with: ->(exception) { do_something(exception) }
      #
      #
      #   # good
      #   rescue_from MyException do |e|
      #     # do something
      #   end
      #
      #   # good
      #   rescue_from MyException do |_e|
      #     # do something
      #   end
      #
      #   # good
      #   rescue_from MyException do |exception, context|
      #     # do something
      #   end
      #
      #   # good
      #   rescue_from MyException { |e| do_something(e) }
      #
      #   # good
      #   rescue_from MyException, with: ->(e) do
      #     do_something(e)
      #   end
      #
      #   # good
      #   rescue_from MyException, with: ->(e) { do_something(e) }
      #
      # @example PreferredName: exception
      #   # bad
      #   rescue_from MyException do |e|
      #     # do something
      #   end
      #
      #   # bad
      #   rescue_from MyException do |_e|
      #     # do something
      #   end
      #
      #   # bad
      #   rescue_from MyException do |exception, context|
      #     # do something
      #   end
      #
      #   # bad
      #   rescue_from MyException { |e| do_something(e) }
      #
      #   # bad
      #   rescue_from MyException, with: ->(e) do
      #     do_something(e)
      #   end
      #
      #   # bad
      #   rescue_from MyException, with: ->(e) { do_something(e) }
      #
      #
      #   # good
      #   rescue_from MyException do |exception|
      #     # do something
      #   end
      #
      #   # good
      #   rescue_from MyException do |_exception|
      #     # do something
      #   end
      #
      #   # good
      #   rescue_from MyException { |exception| do_something(exception) }
      #
      #   # good
      #   rescue_from MyException, with: ->(exception) do
      #     do_something(exception)
      #   end
      #
      #   # good
      #   rescue_from MyException, with: ->(exception) { do_something(exception) }
      #
      class RescueFromExceptionsVariableName < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        MSG = 'Use `%<preferred>s` instead of `%<current>s`.'
        RESTRICT_ON_SEND = %i[rescue_from].freeze

        def_node_matcher :rescue_from_block_argument_variable?, <<~PATTERN
          (block (send nil? :rescue_from ...) (args (arg $_)) _)
        PATTERN

        def_node_matcher :rescue_from_with_lambda_variable?, <<~PATTERN
          (send nil? :rescue_from ... (hash <(pair (sym :with) (block _ (args (arg $_)) _))>))
        PATTERN

        def_node_matcher :rescue_from_with_block_variable?, <<~PATTERN
          (send nil? :rescue_from ... {(block _ (args (arg $_)) _) (splat (block _ (args (arg $_)) _))})
        PATTERN

        def on_block(node)
          rescue_from_block_argument_variable?(node) do |arg_name|
            check_offense(node.first_argument, arg_name)
          end
        end
        alias on_numblock on_block

        def on_send(node)
          check_rescue_from_variable(node, :rescue_from_with_lambda_variable?)
          check_rescue_from_variable(node, :rescue_from_with_block_variable?)
        end

        private

        def check_rescue_from_variable(node, matcher)
          send(matcher, node) do |arg_name|
            arg_node = node.each_descendant(:args).first.children.first
            check_offense(arg_node, arg_name)
          end
        end

        def check_offense(arg_node, arg_name)
          preferred_name = preferred_name(arg_name)
          return if arg_name.to_s == preferred_name

          range = adjusted_range(arg_node)
          preferred, current = format_names(arg_node, arg_name, preferred_name)
          message = format(MSG, preferred: preferred, current: current)

          add_offense(range, message: message) do |corrector|
            autocorrect(corrector, range, preferred, arg_node, preferred_name)
          end
        end

        def preferred_name(name)
          config_name = cop_config.fetch('PreferredName', 'e')
          name.start_with?('_') ? "_#{config_name}" : config_name
        end

        def adjusted_range(arg_node)
          arg_node.source_range.with(
            begin_pos: arg_node.source_range.begin_pos - 1,
            end_pos: arg_node.source_range.end_pos + 1
          )
        end

        def format_names(arg_node, arg_name, preferred_name)
          if arg_node.parent.parent.lambda?
            ["(#{preferred_name})", "(#{arg_name})"]
          else
            ["|#{preferred_name}|", "|#{arg_name}|"]
          end
        end

        def autocorrect(corrector, range, preferred, arg_node, preferred_name)
          corrector.replace(range, preferred)
          parent_block = arg_node.ancestors.find(&:block_type?)

          parent_block.each_descendant(:lvar).each do |lvar_node|
            corrector.replace(lvar_node, preferred_name)
          end
        end
      end
    end
  end
end
