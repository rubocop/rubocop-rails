# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Looks for duplicate action names in the `only` and `except` options of controller callbacks.
      #
      # @example
      #   # bad
      #   before_action :my_method, only: %i[index index show]
      #
      #   # good
      #   before_action :my_method, only: %i[index show]
      #
      #   # bad
      #   around_action :some_method, except: [:index, :index, :show]
      #
      #   # good
      #   around_action :some_method, except: [:index, :show]
      class CallbackOptionsUniqueness < Base
        # raise NotImplementedError
      end
    end
  end
end
