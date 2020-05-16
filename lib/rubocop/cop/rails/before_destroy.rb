# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Rails
      # This cop checks that `before_destroy` callbacks
      # are executed before ActiveRecord associations
      # that are marked as `dependent: :destroy`.
      # See: https://guides.rubyonrails.org/active_record_callbacks.html#destroying-an-object
      #
      # @example
      #   # bad
      #   has_many :entities, dependent: :destroy
      #   before_destroy { do_something }
      #
      #   # good
      #   before_destroy { do_something }
      #   has_many :entities, dependent: :destroy
      #
      #   # good
      #   has_many :entities, dependent: :destroy
      #   before_destroy(prepend: true) { do_something }
      #
      class BeforeDestroy < Cop
        MSG = '"before_destroy" callbacks must run before "dependent: :destroy" associations.'

        def_node_matcher :before_destroy?, <<~PATTERN
          (send _ :before_destroy ...)
        PATTERN

        def_node_search :association_nodes, <<~PATTERN
          (send nil? {:has_many :has_one :belongs_to} _ (hash ...))
        PATTERN

        def_node_matcher :hash_options, <<~PATTERN
          `(hash $...)
        PATTERN

        def_node_matcher :dependent_destroy?, <<~PATTERN
          (pair (sym :dependent) (sym :destroy))
        PATTERN

        def_node_matcher :prepend_true?, <<~PATTERN
          (pair (sym :prepend) true)
        PATTERN

        def on_send(node)
          return unless before_destroy?(node)
          return if has_prepend_true?(node)

          root_class_node = node.each_ancestor(:class).first
          return unless potentially_offending_association_nodes(root_class_node).any? do |association_node|
            association_node.first_line < node.first_line
          end

          add_offense(node)
        end

        private

        def has_prepend_true?(before_destroy_node)
          node_hash_options = hash_options(before_destroy_node)
          return false unless node_hash_options

          node_hash_options.any?(&method(:prepend_true?))
        end

        def potentially_offending_association_nodes(root_class_node)
          potential_violations = []

          association_nodes(root_class_node).each do |association_node|
            association_options = hash_options(association_node)
            next unless association_options

            has_dependent_destroy = association_options.any?(&method(:dependent_destroy?))
            potential_violations << association_node if has_dependent_destroy
          end

          potential_violations
        end
      end
    end
  end
end
