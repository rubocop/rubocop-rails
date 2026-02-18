# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for uses of `connection.execute` in migrations.
      #
      # This cop enforces using `execute` directly.
      #
      # @example
      #   # bad
      #   class AddIndexToUsers < ActiveRecord::Migration[7.0]
      #     def up
      #       connection.execute('CREATE INDEX index_users_on_email ON users(email)')
      #     end
      #   end
      #
      #   # good
      #   class AddIndexToUsers < ActiveRecord::Migration[7.0]
      #     def up
      #       execute('CREATE INDEX index_users_on_email ON users(email)')
      #     end
      #   end
      class MigrationExecute < Base
        include MigrationsHelper
        extend AutoCorrector

        MSG = 'Use `execute` instead of `connection.execute` in migrations.'
        RESTRICT_ON_SEND = %i[execute].freeze

        # @!method connection_execute?(node)
        def_node_matcher :connection_execute?, <<~PATTERN
          (call (send {nil? self} :connection) :execute ...)
        PATTERN

        def on_send(node)
          return unless in_migration?(node)
          return unless connection_execute?(node)

          add_offense(node.receiver) do |corrector|
            corrector.remove(node.receiver.source_range.join(node.loc.dot))
          end
        end
        alias on_csend on_send
      end
    end
  end
end
