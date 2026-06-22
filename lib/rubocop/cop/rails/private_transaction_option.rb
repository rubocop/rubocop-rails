# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks whether `ActiveRecord::Base.transaction(joinable: _)` is used.
      #
      # The `joinable` option is a private API and is not intended to be called
      # from outside Active Record core.
      # https://github.com/rails/rails/issues/39912#issuecomment-665483779
      # https://github.com/rails/rails/issues/46182#issuecomment-1265966330
      #
      # Passing `joinable: false` may cause unexpected behavior such as the
      # `after_commit` callback not firing at the appropriate time.
      #
      # @safety
      #   This Cop is unsafe because it cannot accurately identify
      #   the `ActiveRecord::Base.transaction` method call.
      #
      # @example
      #   # bad
      #   ActiveRecord::Base.transaction(requires_new: true, joinable: false)
      #
      #   # good
      #   ActiveRecord::Base.transaction(requires_new: true)
      #
      class PrivateTransactionOption < Base
        MSG = 'Use a negated `requires_new` option instead of the internal `joinable`.'
        RESTRICT_ON_SEND = %i[transaction].freeze

        # @!method match_transaction_with_joinable(node)
        def_node_matcher :match_transaction_with_joinable, <<~PATTERN
          (send _ :transaction (hash <$(pair (sym :joinable) {true false}) ...>))
        PATTERN

        def on_send(node)
          match_transaction_with_joinable(node) do |option_node|
            add_offense(option_node)
          end
        end
      end
    end
  end
end
