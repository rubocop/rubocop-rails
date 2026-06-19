# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for usage of `Rails.env` which can be replaced with Feature Flags.
      #
      # Predicate methods listed in `AllowedPredicates` are not flagged. The default
      # list covers the `String` / `StringInquirer` predicates that aren't
      # environment-specific (e.g. `empty?`, `match?`, `between?`). The configured
      # value fully replaces the default — to exempt an additional predicate
      # such as `Rails.env.local?` (or a custom predicate monkey-patched onto
      # the environment inquirer) while preserving the defaults, list them all
      # together. Merge semantics can be opted into via RuboCop's `inherit_mode`.
      #
      # [source,yaml]
      # ----
      #  Rails/Env:
      #    AllowedPredicates:
      #      - empty?
      #      - match?
      #      - local?
      # ----
      #
      # @example
      #
      #   # bad
      #   Rails.env.production? || Rails.env.local?
      #
      #   # good
      #   if FeatureFlag.enabled?(:new_feature)
      #     # new feature code
      #   end
      #
      class Env < Base
        MSG = 'Use Feature Flags or config instead of `Rails.env`.'
        RESTRICT_ON_SEND = %i[env].freeze

        def on_send(node)
          return unless node.receiver&.const_name == 'Rails'

          parent = node.parent
          return unless parent.respond_to?(:predicate_method?) && parent.predicate_method?

          return if allowed_predicates.include?(parent.method_name)

          add_offense(parent)
        end

        private

        def allowed_predicates
          @allowed_predicates ||= Array(cop_config['AllowedPredicates']).to_set(&:to_sym)
        end
      end
    end
  end
end
