# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for access of app secrets and credentials.
      # If there is a typo in the key name, direct access silently returns
      # nil and can lead to subtle bugs. Fetch raises an error upfront.
      #
      # @example
      #   # bad
      #   Rails.application.secrets.foo
      #   Rails.application.credentials.bar
      #
      #   # good
      #   Rails.application.secrets.fetch(:foo)
      #   Rails.application.credentials.fetch(:bar)
      #   Rails.application.credentials.fetch(:baz, "default_baz")
      class CredentialsDirectAccess < Cop
        MSG = 'Prefer fetch over direct access.'

        def_node_matcher :direct_access?, <<-PATTERN
          (send (send (send (const nil? :Rails) :application) ${:secrets :credentials}) _)
        PATTERN

        def on_send(node)
          add_offense(node, location: :selector) if direct_access?(node)
        end

        def autocorrect(node)
          selector = node.loc.selector
          lambda do |corrector|
            corrector.replace(selector, "fetch(:#{selector.source})")
          end
        end
      end
    end
  end
end
