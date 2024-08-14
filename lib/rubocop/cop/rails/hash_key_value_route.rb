# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Avoid Hash key-value routing.
      # Drawing a route in this style will be removed in Rails 8.1.
      #
      # @safety
      #   This cop is unsafe because it is implemented on the assumption that
      #   the first element of Hash always contains path and endpoint, based on
      #   the background that it is often so written.
      #
      # @example
      #   # bad
      #   get '/users' => 'users#index'
      #
      #   # good
      #   get '/users', to: 'users#index'
      #
      #   # bad
      #   mount MyApp => '/my_app'
      #
      #   # good
      #   mount MyApp, at: '/my_app'
      class HashKeyValueRoute < Base
        extend AutoCorrector

        MSG = 'Avoid Hash key-value routing.'

        RESTRICT_ON_SEND = %i[delete get match mount options patch post put].freeze

        # @!method hash_key_value_route(node)
        def_node_matcher :hash_key_value_route, <<~PATTERN
          (send
            nil?
            _
            (hash
              $(pair $_ $_)
              ...
            )
          )
        PATTERN

        def on_send(node)
          hash_key_value_route(node) do |pair, key, value|
            add_offense(pair) do |corrector|
              corrector.replace(pair, "#{key.source}, #{option_name(node)}: #{value.source}")
            end
          end
        end

        private

        def option_name(node)
          if node.method?(:mount)
            'at'
          else
            'to'
          end
        end
      end
    end
  end
end
