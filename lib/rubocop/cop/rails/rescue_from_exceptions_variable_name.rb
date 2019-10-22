# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop makes sure that rescued exceptions variables are named as
      # expected.
      #
      # The `PreferredName` config option takes a `String`. It represents
      # the required name of the variable. Its default is `e` that is read
      # from `Naming/RescuedExceptionsVariableName` cop in the main Rubocop
      # repository.
      #
      # @example PreferredName: e (default)
      #   # bad
      #   rescue_from MyException do |exception|
      #     # do something
      #   end
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
      # @example PreferredName: exception
      #   # bad
      #   rescue_from MyException do |e|
      #     # do something
      #   end
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
      class RescueFromExceptionsVariableName < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Use `%<preferred>s` instead of `%<bad>s`.'

        def on_block(node)
          name = variable_name(node)
          return unless name
          return if preferred_name(name).to_sym == name

          add_offense(node, location: offense_range(node))
        end

        def autocorrect(node)
          lambda do |corrector|
            offending_name = variable_name(node)
            preferred_name = preferred_name(offending_name)
            corrector.replace(offense_range(node), "|#{preferred_name}|")
          end
        end

        private

        def offense_range(resbody)
          variable = resbody.node_parts[1]
          variable.loc.expression
        end

        def preferred_name(variable_name)
          preferred_name = cop_config.fetch('PreferredName', 'e')
          if variable_name.to_s.start_with?('_')
            "_#{preferred_name}"
          else
            preferred_name
          end
        end

        def variable_name(node)
          asgn_node = node.node_parts[1]
          return unless asgn_node

          asgn_node.children.last&.source&.to_sym
        end

        def message(node)
          offending_name = variable_name(node)
          preferred_name = preferred_name(offending_name)
          format(MSG, preferred: preferred_name, bad: offending_name)
        end
      end
    end
  end
end
