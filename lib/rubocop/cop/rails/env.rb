# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for usage of `Rails.env` which can be replaced with Feature Flags
      #
      # The cop does not flag `Rails.env.local?`, the built-in alias for
      # "development or test" introduced in Rails 7.1. Unlike per-environment
      # predicates such as `development?` or `production?`, `local?` expresses
      # the intent of guarding code that must only ever run in development or
      # test (sanity checks, devtools, seed data) rather than gating an
      # environment rollout, so a Feature Flag is not a suitable replacement.
      #
      # @example
      #
      #   # bad
      #   Rails.env.production? || Rails.env.development?
      #
      #   # good
      #   if FeatureFlag.enabled?(:new_feature)
      #     # new feature code
      #   end
      #
      #   # good
      #   raise 'This should never run in production' unless Rails.env.local?
      #
      class Env < Base
        MSG = 'Use Feature Flags or config instead of `Rails.env`.'
        RESTRICT_ON_SEND = %i[env].freeze
        # This allow list is derived from:
        # (Rails.env.methods - Object.instance_methods).select { |m| m.to_s.end_with?('?') }
        # and then removing the environment specific methods like development?, test?, and production?.
        # `local?` is kept on the allow list because it intentionally expresses
        # "development or test" rather than a single environment rollout.
        ALLOWED_LIST = Set.new(
          %i[
            unicode_normalized?
            exclude?
            empty?
            acts_like_string?
            include?
            is_utf8?
            casecmp?
            match?
            starts_with?
            ends_with?
            start_with?
            end_with?
            valid_encoding?
            ascii_only?
            between?
            local?
          ]
        ).freeze

        def on_send(node)
          return unless node.receiver&.const_name == 'Rails'

          parent = node.parent
          return unless parent.respond_to?(:predicate_method?) && parent.predicate_method?

          return if ALLOWED_LIST.include?(parent.method_name)

          add_offense(parent)
        end
      end
    end
  end
end
