# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Ensures that `before_destroy` callbacks are executed
      # before `dependent: :destroy` associations by requiring
      # the `prepend: true` option.
      #
      # Without `prepend: true`, `before_destroy` callbacks may run
      # after associated records are already deleted, leading to
      # unintended behavior.
      #
      # @example
      #   # bad
      #   has_many :entities, dependent: :destroy
      #   before_destroy { do_something }
      #
      #   # good
      #   has_many :entities, dependent: :destroy
      #   before_destroy(prepend: true) { do_something }
      #
      # @example
      #   # bad
      #   belongs_to :entity, dependent: :destroy
      #   before_destroy :some_method
      #
      #   # good
      #   belongs_to :entity, dependent: :destroy
      #   before_destroy :some_method, prepend: true
      #
      # @example
      #   # bad
      #   has_one :entity, dependent: :destroy
      #   before_destroy MyClass.new
      #
      #   # good
      #   has_one :entity, dependent: :destroy
      #   before_destroy MyClass.new, prepend: true
      #
      # @example
      #   # bad
      #   has_many :entities, dependent: :destroy
      #   before_destroy -> { do_something }
      #
      #   # good
      #   has_many :entities, dependent: :destroy
      #   before_destroy -> { do_something }, prepend: true
      #
      class BeforeDestroy < Base
        extend AutoCorrector

        MSG = '"before_destroy" callbacks must be declared before "dependent: :destroy" associations ' \
              'or use `prepend: true`.'
        RESTRICT_ON_SEND = %i[before_destroy].freeze

        def_node_search :association_nodes, <<~PATTERN
          (send nil? {:belongs_to :has_one :has_many} _ (hash ...))
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
          check_add_prepend_true(node)
          check_remove_prepend_true(node)
        end

        private

        def check_add_prepend_true(node)
          return if contains_prepend_true?(node)
          return unless before_association_with_dependent_destroy?(node)

          add_offense(node) { |corrector| autocorrect_add_prepend(corrector, node) }
        end

        def check_remove_prepend_true(node)
          return unless contains_prepend_true?(node)
          return if before_any_association?(node)

          add_offense(node) { |corrector| autocorrect_remove_prepend(corrector, node) }
        end

        def autocorrect_remove_prepend(corrector, node)
          prepend_pair = hash_options(node).find { |pair| prepend_true?(pair) }
          prepend_range = prepend_pair.source_range
          start_pos, end_pos = adjust_removal_range(prepend_range)

          corrector.remove(prepend_range.with(begin_pos: start_pos, end_pos: end_pos))
          remove_block_delimiters(corrector, node)
        end

        def autocorrect_add_prepend(corrector, node)
          hash_node = node.arguments.find(&:hash_type?)

          if hash_node
            corrector.insert_before(hash_node.children.first, 'prepend: true, ')
          elsif node.arguments.empty?
            corrector.insert_after(node.loc.selector, '(prepend: true)')
          else
            corrector.insert_after(node.last_argument, ', prepend: true')
          end
        end

        def adjust_removal_range(prepend_range)
          start_pos = prepend_range.begin_pos
          end_pos = prepend_range.end_pos

          source = processed_source.buffer.source

          prev_match = source[0...start_pos].match(/,\s*$/)
          next_match = source[end_pos..].match(/^\s*,?/)

          if prev_match
            start_pos = prev_match.begin(0)
          elsif next_match
            end_pos += next_match.end(0)
          end

          [start_pos, end_pos]
        end

        def remove_block_delimiters(corrector, node)
          return unless node.block_literal?
          return unless node.loc.begin

          corrector.remove(node.loc.begin)
          corrector.remove(node.loc.end)
        end

        def before_association_with_dependent_destroy?(node)
          root_class_node = find_root_class(node)
          association_nodes(root_class_node).any? do |assoc|
            contains_dependent_destroy?(assoc) && assoc.first_line < node.first_line
          end
        end

        def before_any_association?(node)
          root_class_node = find_root_class(node)
          association_nodes(root_class_node).any? do |assoc|
            assoc.first_line < node.first_line
          end
        end

        def find_root_class(node)
          node.each_ancestor(:class, :module).first
        end

        def contains_prepend_true?(node)
          hash_options(node)&.any? { |pair| prepend_true?(pair) }
        end

        def contains_dependent_destroy?(node)
          hash_options(node).any? { |pair| dependent_destroy?(pair) }
        end
      end
    end
  end
end
