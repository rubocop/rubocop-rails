# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Prevent defining constants in config/routes.rb files.
      #
      # Defining constants in a routes.rb file can lead to constant redefinition
      # warnings because routes.rb is a reloadable file.
      #
      # @example
      #   # bad
      #   Rails.application.routes.draw do
      #     ADMIN_CONSTRAINT = ->(req) { req.subdomain == 'admin' }
      #
      #     get "/users", constraints: ADMIN_CONSTRAINT
      #   end
      #
      #   # good
      #   Rails.application.routes.draw do
      #     admin_constraint = ->(req) { req.subdomain == 'admin' }
      #
      #     get "/users", constraints: admin_constraint
      #   end
      #
      class ConstantInRoutes < Base
        MSG = 'Do not define constants in config/routes.rb. Use a local variable or move this constant somewhere else.'

        def on_casgn(node)
          return unless in_routes_file?

          add_offense(node)
        end

        private

        def in_routes_file?
          processed_source.file_path&.end_with?('config/routes.rb')
        end
      end
    end
  end
end
