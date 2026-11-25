# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for redundant `class_names` calls in the `class` option of tag helpers.
      #
      # Since Rails 6.1, tag helpers build the `class` attribute out of arrays and hashes
      # themselves, so wrapping the same arguments in `class_names` only adds noise.
      # An array literal is enough.
      #
      # @example
      #   # bad
      #   tag.div class: class_names('foo', 'bar': condition)
      #   content_tag :div, 'text', class: class_names('foo', 'bar': condition)
      #   link_to 'text', path, class: class_names('foo', 'bar': condition)
      #
      #   # good
      #   tag.div class: ['foo', 'bar': condition]
      #   content_tag :div, 'text', class: ['foo', 'bar': condition]
      #   link_to 'text', path, class: ['foo', 'bar': condition]
      #
      #   # good
      #   tag.div class: class_names('foo', 'bar': condition).presence
      #   render 'card', class: class_names('foo', 'bar': condition)
      #
      class RedundantClassNames < Base
        include RangeHelp
        extend AutoCorrector
        extend TargetRailsVersion

        minimum_target_rails_version 6.1

        MSG = 'Use an array literal instead of a redundant `class_names` call.'
        RESTRICT_ON_SEND = %i[class_names].freeze

        TAG_HELPERS = %i[
          button_to content_tag image_tag link_to link_to_if link_to_unless link_to_unless_current mail_to tag
        ].freeze

        def on_send(node)
          return unless redundant_class_names?(node)

          add_offense(node) do |corrector|
            corrector.replace(range_between(node.source_range.begin_pos, node.loc.begin.end_pos), '[')
            corrector.replace(node.loc.end, ']')
          end
        end

        private

        def redundant_class_names?(node)
          return false unless node.receiver.nil? && node.parenthesized? && !node.arguments.empty?

          class_option?(node.parent) && tag_helper_options?(node.parent.parent)
        end

        def class_option?(pair)
          return false unless pair&.pair_type?

          key = pair.key
          key.type?(:sym, :str) && key.value.to_s == 'class'
        end

        def tag_helper_options?(hash)
          return false unless hash&.hash_type?

          helper = hash.parent
          return false unless helper&.send_type? && helper.arguments.include?(hash)

          tag_builder?(helper.receiver) || TAG_HELPERS.include?(helper.method_name)
        end

        def tag_builder?(receiver)
          receiver&.send_type? && receiver.method?(:tag) && receiver.arguments.empty?
        end
      end
    end
  end
end
