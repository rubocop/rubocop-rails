# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces the use of `ActionController::Parameters#expect` as a method for strong parameter handling.
      #
      # @safety
      #   This cop's autocorrection is considered unsafe because there are cases where the HTTP status may change
      #   from 500 to 400 when handling invalid parameters. This change, however, reflects an intentional
      #   incompatibility introduced for valid reasons by the `expect` method, which aligns better with
      #   strong parameter conventions.
      #
      # @example
      #
      #   # bad
      #   params.require(:user).permit(:name, :age)
      #   params.permit(user: [:name, :age]).require(:user)
      #
      #   # good
      #   params.expect(user: [:name, :age])
      #
      class StrongParametersExpect < Base
        extend AutoCorrector
        extend TargetRailsVersion

        MSG = 'Use `%<prefer>s` instead.'
        RESTRICT_ON_SEND = %i[require permit].freeze

        minimum_target_rails_version 8.0

        def_node_matcher :params_require_permit, <<~PATTERN
          $(call
            $(call
              (send nil? :params) :require _) :permit _+)
        PATTERN

        def_node_matcher :params_permit_require, <<~PATTERN
          $(call
            $(call
               (send nil? :params) :permit (hash (pair _require_param_name _ )))
                 :require  _require_param_name)
        PATTERN

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def on_send(node)
          return if part_of_ignored_node?(node)

          if (permit_method, require_method = params_require_permit(node))
            range = offense_range(require_method, node)
            prefer = expect_method(require_method, permit_method)
            replace_argument = true
          elsif (require_method, permit_method = params_permit_require(node))
            range = offense_range(permit_method, node)
            prefer = "expect(#{permit_method.arguments.map(&:source).join(', ')})"
            replace_argument = false
          else
            return
          end

          add_offense(range, message: format(MSG, prefer: prefer)) do |corrector|
            corrector.remove(require_method.receiver.source_range.end.join(require_method.source_range.end))
            corrector.replace(permit_method.loc.selector, 'expect')
            if replace_argument
              transformed_arguments = permit_method.arguments.map { |arg| recursive_transform(arg) }.join(', ')
              transformed_string = "#{require_key(require_method)}[#{transformed_arguments}])"

              args_range = permit_method.source_range.with(
                begin_pos: permit_method.first_argument.source_range.begin_pos
              )
              corrector.replace(args_range, transformed_string)
            end
          end

          ignore_node(node)
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
        alias on_csend on_send

        private

        def offense_range(method_node, node)
          method_node.loc.selector.join(node.source_range.end)
        end

        def expect_method(require_method, permit_method)
          require_key = require_key(require_method)

          permit_args = permit_method.arguments.map { |arg| recursive_transform(arg) }.join(', ')

          "expect(#{require_key}[#{permit_args}])"
        end

        def recursive_transform(node, top_level: true)
          case node.type
          when :hash
            elements = hash_elements_from_node(node)
            if top_level
              elements.join(', ')
            else
              elements.empty? ? '{}' : "[#{elements.join(', ')}]"
            end
          when :array
            elements = node.children.map { |child| recursive_transform(child, top_level: false) }
            elements.empty? ? elements : "[[#{elements.join(', ')}]]"
          else
            node.source
          end
        end

        def hash_elements_from_node(node)
          node.pairs.map do |pair|
            key = pair.key.source
            value = recursive_transform(pair.value, top_level: false)
            "#{key}: #{value}"
          end
        end

        def require_key(require_method)
          if (first_argument = require_method.first_argument).respond_to?(:value)
            require_arg = first_argument.value
            separator = ': '
          else
            require_arg = first_argument.source
            separator = ' => '
          end

          "#{require_arg}#{separator}"
        end
      end
    end
  end
end
