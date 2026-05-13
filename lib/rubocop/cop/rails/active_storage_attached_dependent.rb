# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Flags `has_one_attached` / `has_many_attached` declarations whose
      # `dependent:` value silently no-ops in ActiveStorage.
      #
      # Rails stores `dependent:` verbatim on the reflection but only
      # `ActiveStorage::Attachment#purge_dependent_blob_later` consumes it,
      # with strict equality on `:purge_later`. Anything else (`true`, `nil`,
      # `:destroy`, arbitrary symbols) leaves orphan blobs in storage with
      # no warning when the parent record is destroyed.
      #
      # `:purge` is documented but not honored by the consumer today;
      # see https://github.com/rails/rails/issues/36423.
      #
      # @example
      #   # bad - silent no-op
      #   has_one_attached :avatar, dependent: true
      #
      #   # bad - silent no-op
      #   has_many_attached :photos, dependent: :destroy
      #
      #   # bad - documented but not honored, see rails/rails#36423
      #   has_one_attached :avatar, dependent: :purge
      #
      #   # good
      #   has_one_attached :avatar
      #   has_one_attached :avatar, dependent: :purge_later
      #   has_one_attached :avatar, dependent: false
      class ActiveStorageAttachedDependent < Base
        MSG = '`dependent: %<value>s` is silently a no-op in ActiveStorage and ' \
              'leaves orphan blobs in storage. Use `:purge_later` (default) or `false`.'
        MSG_PURGE = '`dependent: :purge` is documented but only `:purge_later` is honored ' \
                    'by ActiveStorage today (rails/rails#36423). Use `:purge_later` (default).'

        RESTRICT_ON_SEND = %i[has_one_attached has_many_attached].freeze

        # @!method dependent_pair(node)
        def_node_matcher :dependent_pair, <<~PATTERN
          (send _ {:has_one_attached :has_many_attached} _
            (hash <$(pair (sym :dependent) _) ...>))
        PATTERN

        def on_send(node)
          return unless (pair = dependent_pair(node))
          return if allowed_value?(pair.value)

          register_offense(pair)
        end
        alias on_csend on_send

        private

        def allowed_value?(value)
          (value.sym_type? && value.value == :purge_later) || value.false_type?
        end

        def register_offense(pair)
          value = pair.value
          if value.sym_type? && value.value == :purge
            add_offense(pair, message: MSG_PURGE, severity: :warning)
          else
            add_offense(pair, message: format(MSG, value: value.source))
          end
        end
      end
    end
  end
end
