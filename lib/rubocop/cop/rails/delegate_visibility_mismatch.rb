# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Flags `delegate` calls whose `private:` option does not match the surrounding
      # visibility scope. `delegate` defines public methods by default and only supports
      # a `private: true` option, so:
      #
      # * under an explicit `private` or `protected` modifier, the call must pass
      #   `private: true`;
      # * under an explicit `public` modifier, the call must not pass `private: true`;
      # * with no explicit visibility modifier, either form is allowed.
      #
      # Autocorrects by inserting, updating, or flipping the `private:` option so it
      # matches the enclosing scope.
      #
      # @safety
      #   This cop's autocorrection is unsafe because it changes the visibility of the
      #   delegated methods. `delegate` defines public methods regardless of the
      #   surrounding visibility scope unless `private: true` is passed, so callers may
      #   be relying on the current (mismatched) visibility.
      #
      # @example
      #   # bad
      #   class Foo
      #     private
      #
      #     delegate :bar, to: :baz
      #   end
      #
      #   # bad
      #   class Foo
      #     protected
      #
      #     delegate :bar, to: :baz
      #   end
      #
      #   # bad
      #   class Foo
      #     public
      #
      #     delegate :bar, to: :baz, private: true
      #   end
      #
      #   # good
      #   class Foo
      #     private
      #
      #     delegate :bar, to: :baz, private: true
      #   end
      #
      #   # good
      #   class Foo
      #     delegate :bar, to: :baz
      #   end
      #
      #   # good (no explicit visibility modifier, so either form is allowed)
      #   class Foo
      #     delegate :bar, to: :baz, private: true
      #   end
      class DelegateVisibilityMismatch < ::RuboCop::Cop::Base
        include VisibilityHelp
        extend ::RuboCop::Cop::AutoCorrector

        MSG = 'Match the `private:` option on `delegate` to the enclosing `%<scope>s` visibility scope.'

        RESTRICT_ON_SEND = %i[delegate].freeze

        def on_send(node)
          return unless node.receiver.nil?

          scope = node_visibility(node)
          should_be_private = scope != :public
          return if !should_be_private && find_visibility_start(node).nil?
          return unless mismatch?(node, should_be_private)

          add_offense(node, message: format(MSG, scope: scope)) do |corrector|
            autocorrect(corrector, node, should_be_private)
          end
        end

        private

        def mismatch?(node, should_be_private)
          if should_be_private
            !private_option_true?(node)
          else
            private_option_true?(node)
          end
        end

        def autocorrect(corrector, node, should_be_private)
          target_value = should_be_private ? 'true' : 'false'
          existing_pair = private_option_pair(node)

          if existing_pair
            corrector.replace(existing_pair.value, target_value)
          else
            corrector.insert_after(node.last_argument, ", private: #{target_value}")
          end
        end

        def options_hash(node)
          last_argument = node.last_argument
          return unless last_argument&.hash_type?

          last_argument
        end

        def private_option_pair(node)
          hash = options_hash(node)
          return unless hash

          hash.pairs.find { |pair| pair.key.sym_type? && pair.key.value == :private }
        end

        def private_option_true?(node)
          pair = private_option_pair(node)
          pair&.value&.true_type? || false
        end
      end
    end
  end
end
