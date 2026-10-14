# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Identifies places where Active Support's `Enumerable#in_groups_of` is used to
      # chunk a collection and, where possible, encourages the Ruby built-in
      # `Enumerable#each_slice` instead.
      #
      # When `in_groups_of` is called without a second argument, the final group is
      # padded with `nil` so that every group has the same size. This padding is easy
      # to forget about and frequently leads to a `NoMethodError` on `nil` (or another
      # `TypeError`) downstream, because the code assumed every element was a real
      # member of the collection. `each_slice` performs the same chunking without
      # inserting `nil` padding, so preferring it prevents this class of bug.
      #
      # Passing an explicit `false` as the second argument (`in_groups_of(number, false)`)
      # is exactly equivalent to `each_slice(number)`, so those calls are reported too under
      # the default `each_slice` style. Any other explicit second argument (including an
      # explicit `nil`) signals that padding is intentional and is left alone.
      #
      # When `EnforcedStyle` is set to `explicit`, calls without a second argument are
      # instead reported with a suggestion to add an explicit second argument, making the
      # padding behavior obvious at the call site rather than switching to `each_slice`. In
      # this style any explicit second argument is accepted, including `false`.
      #
      # This cop does not support autocorrection because it cannot determine whether an
      # omitted second argument reflects an intentional desire to pad groups with `nil`
      # or an oversight that should be replaced with `each_slice`.
      #
      # @safety
      #   This cop is unsafe because `each_slice` and `in_groups_of` are only defined on
      #   different receivers (`in_groups_of` is an Active Support extension), and their
      #   return values differ: `each_slice` without a block returns an `Enumerator`,
      #   while `in_groups_of` without a block returns an `Array`.
      #
      # @example
      #   # bad
      #   collection.in_groups_of(3)
      #
      #   # bad
      #   collection.in_groups_of(3, false)
      #
      #   # good
      #   collection.each_slice(3)
      #
      #   # good
      #   collection.in_groups_of(3, 0)
      #
      # @example EnforcedStyle: each_slice (default)
      #   # bad
      #   collection.in_groups_of(3)
      #
      #   # good
      #   collection.each_slice(3)
      #
      # @example EnforcedStyle: explicit
      #   # bad
      #   collection.in_groups_of(3)
      #
      #   # good
      #   collection.in_groups_of(3, false)
      #
      #   # good
      #   collection.in_groups_of(3, nil)
      class InGroupsOf < Base
        include ConfigurableEnforcedStyle

        MSG_EACH_SLICE = 'Use `each_slice` instead of `in_groups_of` to avoid padding groups with `nil`.'
        MSG_EACH_SLICE_FALSE = 'Prefer `each_slice` instead of `in_groups_of(..., false)` for clarity and simplicity.'
        MSG_EXPLICIT = 'Specify an explicit second argument to `in_groups_of` to make padding behavior explicit.'

        RESTRICT_ON_SEND = %i[in_groups_of].freeze

        def on_send(node)
          return if node.first_argument.nil?

          fill_argument = node.arguments[1]

          if fill_argument.nil?
            add_offense(node.loc.selector, message: style == :explicit ? MSG_EXPLICIT : MSG_EACH_SLICE)
          elsif fill_argument.false_type? && style != :explicit
            add_offense(node.loc.selector, message: MSG_EACH_SLICE_FALSE)
          end
        end
      end
    end
  end
end
