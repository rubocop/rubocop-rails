# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Looks for `before_destroy` without `prepend: true` option.
      #
      # `dependent: :destroy` might cause unexpected deletion of associated records
      # unless `before_destroy` callback had `prepend: true` option.
      #
      # This could cause because `dependent: :destroy` is one of callbacks as well as `before_destroy`,
      # therefore they are run in the order they are defined.
      #
      # Adding `prepend: true` option on `before_destroy` is one of solutions of this happening.
      #
      # @example
      #   # bad
      #   class User < ActiveRecord::Base
      #     has_many :comments, dependent: :destroy
      #
      #     before_destroy :prevent_deletion_if_comments_exists
      #   end
      #
      #   # good
      #   class User < ActiveRecord::Base
      #     has_many :comments, dependent: :destroy
      #
      #     before_destroy :prevent_deletion_if_comments_exists, prepend: true
      #   end
      class PrependTrueOptionOnBeforeDestroy < Base
        extend AutoCorrector

        MSG = 'Add `prepend: true` option on `before_destroy` to prevent unexpected deletion of associated records.'

        RESTRICT_ON_SEND = %i[before_destroy].freeze

        def_node_matcher :match_before_destroy_with_prepend_true_option, <<~PATTERN
          (send _ :before_destroy ...
            (hash <(pair (sym :prepend) true) ...>)
          )
        PATTERN

        def on_send(node)
          return if node.receiver

          matched_node = match_before_destroy_with_prepend_true_option(node)

          return if matched_node

          add_offense(node) do |corrector|
            corrector.insert_after(node, ', prepend: true')
          end
        end
      end
    end
  end
end
