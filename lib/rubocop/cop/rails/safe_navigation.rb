# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Converts usages of `try!` to `&.`. It can also be configured
      # to convert `try`. It will convert code to use safe navigation
      # if the target Ruby version is set to 2.3+
      #
      # @example ConvertTry: false (default)
      #   # bad
      #   foo.try!(:bar)
      #   foo.try!(:bar, baz)
      #   foo.try!(:bar) { |e| e.baz }
      #   foo.try!(&:bar)
      #
      #   foo.try!(:[], 0)
      #   foo.try!(:==, baz)
      #
      #   # good
      #   foo.try(:bar)
      #   foo.try(:bar, baz)
      #   foo.try(:bar) { |e| e.baz }
      #
      #   foo&.bar
      #   foo&.bar(baz)
      #   foo&.bar { |e| e.baz }
      #   foo&.[](0)
      #   foo&.==(baz)
      #
      # @example ConvertTry: true
      #   # bad
      #   foo.try!(:bar)
      #   foo.try!(:bar, baz)
      #   foo.try!(:bar) { |e| e.baz }
      #   foo.try!(&:bar)
      #   foo.try(:bar)
      #   foo.try(:bar, baz)
      #   foo.try(:bar) { |e| e.baz }
      #   foo.try(&:bar)
      #   foo.try(:[], 0)
      #   foo.try(:==, baz)
      #
      #   # good
      #   foo&.bar
      #   foo&.bar(baz)
      #   foo&.bar { |e| e.baz }
      #   foo&.[](0)
      #   foo&.==(baz)
      class SafeNavigation < Base
        include RangeHelp
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 2.3

        MSG = 'Use safe navigation (`&.`) instead of `%<try>s`.'
        RESTRICT_ON_SEND = %i[try try!].freeze

        def_node_matcher :try_call, <<~PATTERN
          (send _ ${:try :try!} $_ ...)
        PATTERN

        # Extracts the method name from a symbol-to-proc block argument, e.g. `:foo` from `try(&:foo)`.
        def_node_matcher :symbol_proc_method, <<~PATTERN
          (block_pass (sym $_))
        PATTERN

        def self.autocorrect_incompatible_with
          [Style::RedundantSelf]
        end

        def on_send(node)
          try_call(node) do |try_method, dispatch|
            return if try_method == :try && !cop_config['ConvertTry']
            return unless dispatch.sym_type? || symbol_proc_method(dispatch)
            # When a `try` is nested in another `try`'s argument, correcting both at once
            # produces overlapping replacements. Correct the outer one first and defer the
            # inner one to a subsequent pass.
            return if part_of_ignored_node?(node)

            add_offense(node, message: format(MSG, try: try_method)) do |corrector|
              autocorrect(corrector, node)
            end
            ignore_node(node)
          end
        end

        private

        def autocorrect(corrector, node)
          method_node, *params = *node.arguments

          range = if node.receiver
                    range_between(node.loc.dot.begin_pos, node.source_range.end_pos)
                  else
                    corrector.insert_before(node, 'self')
                    node
                  end

          corrector.replace(range, replacement(method_node, params))
        end

        def replacement(method_node, params)
          return "&.#{symbol_proc_method(method_node)}" if method_node.block_pass_type?

          method = method_node.source[1..]
          new_params = params.map(&:source).join(', ')

          if setter_method?(method)
            "&.#{method[0...-1]} = #{new_params}"
          elsif params.empty?
            "&.#{method}"
          else
            "&.#{method}(#{new_params})"
          end
        end

        # Operator methods such as `==` and `[]=` also end with `=`, but they are not setters
        # and must keep the explicit call form (e.g. `&.==(bar)`, `&.[]=(key, value)`).
        def setter_method?(method)
          method.match?(/\A\w+=\z/)
        end
      end
    end
  end
end
