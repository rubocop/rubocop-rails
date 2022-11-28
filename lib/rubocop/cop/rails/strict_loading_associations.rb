# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Declare a `strict_loading` option on `has_many` associations.
      #
      # @example
      #
      #   # bad
      #   has_many :posts
      #
      #   # good
      #   has_many :posts, strict_loading: true
      #
      #   # good
      #   has_many :posts, strict_loading: false
      #
      class StrictLoadingAssociations < Base
        extend TargetRailsVersion

        minimum_target_rails_version 6.1

        MSG = 'Declare a `strict_loading` option on `has_many` associations.'

        RESTRICT_ON_SEND = %i[has_many].freeze

        # @!method has_many_association(node)
        # rubocop:disable Naming/PredicateName
        def_node_matcher :has_many_association, <<~PATTERN
          (send nil? :has_many _ $hash ?)
        PATTERN
        # rubocop:enable Naming/PredicateName

        def on_send(node)
          has_many_association(node) do |options|
            add_offense(node) unless strict_loading_declared?(options.first)
          end
        end

        private

        def strict_loading_declared?(options)
          return false if options.nil?

          options.each_key.any? { |k| k.value.to_s == 'strict_loading' }
        end
      end
    end
  end
end
