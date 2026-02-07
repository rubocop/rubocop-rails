# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces the use of `ActionController::Parameters#expect` as a method for strong parameter handling.
      #
      # In the following cases, `params[:key]` is treated as a key that is expected to be passed from the HTTP client,
      # and the cop detects it using the `expect` method.
      #
      # - Method calls on `params[:key]` without comparison methods
      # - Passing `params[:key]` as an argument to finder methods that raise on missing records
      # - Strong parameter methods using `require` or `permit`
      #
      # Other cases are not detected, as they are cases where `params[:key]` may not be passed from the HTTP client.
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
      #   params[:key].do_something
      #
      #   # good
      #   params.expect(:key).do_something
      #
      #   # bad
      #   Model.find(params[:id])
      #
      #   # good
      #   Model.find(params.expect(:id))
      #
      #   # bad
      #   Model.find_by!(key: params[:key])
      #
      #   # good
      #   Model.find_by!(key: params.expect(:key))
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
        RESTRICT_ON_SEND = %i[[] require permit].freeze
        PRESENCE_CHECK_METHODS = %i[nil? blank? present?].freeze
        RAISING_FINDER_METHODS = %i[find find_by! find_sole_by].freeze

        minimum_target_rails_version 8.0

        def_node_matcher :params_bracket_access, <<~PATTERN
          (send (send nil? :params) :[] $_)
        PATTERN

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

          if (params_key = params_bracket_access(node))
            register_bracket_access_offense(node, params_key)
            return
          end

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
              corrector.insert_before(permit_method.first_argument, "#{require_key(require_method)}[")
              corrector.insert_after(permit_method.last_argument, ']')
            end
          end

          ignore_node(node)
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
        alias on_csend on_send

        private

        def register_bracket_access_offense(node, params_key)
          return unless offensive_bracket_access?(node)

          range = offense_range(node, node)
          prefer = "expect(#{params_key.source})"

          add_offense(range, message: format(MSG, prefer: prefer)) do |corrector|
            corrector.replace(range, ".#{prefer}")
          end
        end

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def offensive_bracket_access?(node)
          return false unless (parent = node.parent)
          return false if parent.or_type?
          return true if parent.each_ancestor(:call).any? { |node| raising_finder_method?(node) }
          return false unless parent.call_type?

          if parent.receiver == node
            return false if parent.comparison_method?

            !parent.method?(:[]) && !PRESENCE_CHECK_METHODS.include?(parent.method_name)
          else
            raising_finder_method?(parent)
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        def raising_finder_method?(node)
          RAISING_FINDER_METHODS.include?(node.method_name)
        end

        def offense_range(method_node, node)
          method_node.loc.selector.join(node.source_range.end)
        end

        def expect_method(require_method, permit_method)
          require_key = require_key(require_method)
          permit_args = permit_method.arguments.map(&:source).join(', ')

          arguments = "#{require_key}[#{permit_args}]"

          "expect(#{arguments})"
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
