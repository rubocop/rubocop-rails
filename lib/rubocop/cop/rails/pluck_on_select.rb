# typed: false
# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Do not use .pluck on .select.
      #
      # - .select returns an ActiveRecord relation with only the selected column(s) marked for retrieval
      # - .pluck returns an array of column values
      #
      # Using them together is at best redundant and at worst confusing and inefficient.
      # When chained with .select, .pluck is unaware of any directive passed to .select
      # (e.g. column aliases or a DISTINCT clause). This can lead to unexpected behavior.
      #
      # @example
      #
      #   # before
      #   User.select(:id).pluck(:id)
      #
      #   # after
      #   User.pluck(:id)
      #
      #   # The .select is redundant. Use either .select or .pluck on its own.
      #
      # @example
      #
      #   # before
      #   User.select('id, email AS user_email').pluck('id', 'user_email')
      #
      #   # after
      #   User.pluck(:id, :email)
      #
      #   # after
      #   User.select(:id, 'email AS user_email')
      #
      #   # .pluck is unaware of the alias created by .select and will raise an "Unknown column" error.
      #   # If you need the alias, use .select on its own. Otherwise, consider using .pluck on its own.
      #
      # @example
      #
      #   # before
      #   User.select('DISTINCT email').pluck(:email)
      #
      #   # after
      #   User.group(:email).pluck(:email)
      #
      #   # after
      #   User.distinct.pluck(:email)
      #
      #   # after
      #   User.distinct.select(:email)
      #
      #   # .pluck is unaware of .select's DISTINCT directive and will load all User emails from the
      #   # database - including duplicates. Use either .select or .pluck on its own with .distinct,
      #   # or use .group (which can be more efficient).
      #
      # @example
      #
      #   # before
      #   User.select(:company_id).distinct.pluck(:company_id)
      #
      #   # after
      #   User.group(:company_id).pluck(:company_id)
      #
      #   # after
      #   User.distinct.pluck(:company_id)
      #
      #   # after
      #   User.distinct.select(:company_id)
      #
      #   # The .select is redundant. Use either .select or .pluck on its own with .distinct,
      #   # or use .group (which can be more efficient).
      #
      # @example EnforcedStyle: aggressive
      #
      #   # before
      #   User.select(&:active?).pluck(:id)
      #
      #   # after
      #   User.where(active: true).pluck(:id)
      #
      #   # after (caution - potentially memory-intensive)
      #   User.select(&:active?).map(&:id)
      #
      #   # after (caution - potentially memory-intensive)
      #   User.filter(&:active?).map(&:id)
      #
      #   # .select and .pluck make this statement look like an ActiveRecord operation, but under the hood
      #   # .select is loading all Users into memory before filtering them using the active? method in Ruby.
      #   # Use .where to avoid loading all Users into memory, or use .filter or .map to make it
      #   # clear to readers this is not an ActiveRecord operation.
      #
      class PluckOnSelect < Base
        include ConfigurableEnforcedStyle

        RESTRICT_ON_SEND = %i[pluck].freeze
        MSG = 'Do not use `.pluck` on `.select`.'

        def on_send(node)
          return unless node.receiver

          # Check if any receiver in the chain is a select method
          add_offense(node) if contains_select_in_chain?(node)
        end

        private

        # Helper method to check if the chain contains a select method
        def contains_select_in_chain?(node)
          return false unless node.receiver

          receiver = node.receiver
          while receiver
            if receiver.send_type? && receiver.method?(:select)
              # For conservative style, ignore if select has a block argument
              return false if style == :conservative && block_argument?(receiver)

              return true
            end
            receiver = receiver.receiver
          end
          false
        end

        def block_argument?(node)
          # Check if the first argument is a block pass (&:something)
          node.first_argument&.block_pass_type?
        end

        alias on_csend on_send
      end
    end
  end
end
