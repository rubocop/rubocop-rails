# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Disallows including view helper modules outside of view contexts.
      #
      # View helpers (modules in the `ActionView::Helpers` namespace or
      # following the `*Helper` naming convention) depend on the view context.
      # Including them outside of views or other helpers may cause methods to
      # fail silently or raise errors because they rely on view context that
      # is not present (e.g. `url_for`, `link_to`, `content_tag`).
      #
      # Modules in `app/helpers` are automatically included into all views by
      # Rails and should stay there. If you need shared behavior across
      # multiple classes (controllers, models, jobs, etc.), extract it into a
      # concern under `app/concerns` instead.
      #
      # In controllers, use the `helpers` proxy to call helper methods:
      # `helpers.the_method`. From anywhere else (e.g. a background job),
      # use `ApplicationController.helpers.the_method`.
      #
      # @example
      #   # bad
      #   class UsersController < ApplicationController
      #     include UserHelper
      #   end
      #
      #   # bad
      #   class User < ApplicationRecord
      #     include ApplicationHelper
      #   end
      #
      #   # bad
      #   class MyJob < ApplicationJob
      #     include ActionView::Helpers::NumberHelper
      #   end
      #
      #   # good - use the helpers proxy in controllers
      #   class UsersController < ApplicationController
      #     def show
      #       @formatted = helpers.format_user_name(@user)
      #     end
      #   end
      #
      #   # good - extract shared behavior into a concern
      #   # app/concerns/currency_formattable.rb
      #   module CurrencyFormattable
      #     extend ActiveSupport::Concern
      #
      #     def format_currency(amount)
      #       # pure Ruby formatting, no view context needed
      #     end
      #   end
      #
      #   class MyJob < ApplicationJob
      #     include CurrencyFormattable
      #   end
      #
      class IncludeViewHelper < Base
        MSG = 'Do not include view helpers outside of the view context. Use a concern or the `helpers` proxy instead.'

        RESTRICT_ON_SEND = %i[include].freeze

        def_node_matcher :view_helper_module?, <<~PATTERN
          (const ...)
        PATTERN

        def on_send(node)
          node.arguments.each do |arg|
            next unless view_helper_module?(arg)

            name = arg.source.delete_prefix('::')
            next unless view_helper?(name)

            add_offense(node)
            break
          end
        end

        private

        def view_helper?(name)
          action_view_helper?(name) || helper_by_convention?(name)
        end

        def action_view_helper?(name)
          name.start_with?('ActionView::Helpers::')
        end

        def helper_by_convention?(name)
          name.split('::').last.end_with?('Helper')
        end
      end
    end
  end
end
