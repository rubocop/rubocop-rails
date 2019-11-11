# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop disallows adding new models to the `app/models` directory.
      #
      # The goal is to encourage developers to put new models inside Rails
      # Engines (or at least namespaces), where they can be more modularly
      # isolated and ownership is clear.
      #
      # Use RuboCop's standard `Exclude` file list parameter to exclude
      # existing global model files from counting as violations for this cop.
      #
      # @example AllowNamespacedGlobalModels: true (default)
      #   # When `AllowNamespacedGlobalModels` is true, the cop only forbids
      #   # additions at the top-level directory.
      #
      #   # bad
      #   # path: app/models/my_new_global_model.rb
      #   class MyNewGlobalModel < ApplicationRecord
      #     # ...
      #   end
      #
      #   # good
      #   # path: app/models/my_namespace/my_new_global_model.rb
      #   class MyNamespace::MyNewGlobalModel < ApplicationRecord
      #     # ...
      #   end
      #
      #   # good
      #   # path: engines/my_engine/app/models/my_engine/my_new_engine_model.rb
      #   class MyEngine::MyNewEngineModel < ApplicationRecord
      #     # ...
      #   end
      #
      # @example AllowNamespacedGlobalModels: false
      #   # When `AllowNamespacedGlobalModels` is false, the cop forbids all
      #   # new models in this directory and its descendants.
      #
      #   # bad
      #   # path: app/models/my_new_global_model.rb
      #   class MyNewGlobalModel < ApplicationRecord
      #     # ...
      #   end
      #
      #   # bad
      #   # path: app/models/my_namespace/my_new_global_model.rb
      #   class MyNamespace::MyNewGlobalModel < ApplicationRecord
      #     # ...
      #   end
      #
      #   # good
      #   # path: engines/my_engine/app/models/my_engine/my_new_engine_model.rb
      #   class MyEngine::MyNewEngineModel < ApplicationRecord
      #     # ...
      #   end
      class NewGlobalModel < Cop
        ALLOW_NAMESPACES_MSG =
          'Do not add new top-level global models in `app/models`. ' \
          'Prefer namespaced models like `app/models/foo/bar.rb` or ' \
          'or models inside Rails Engines.'

        DISALLOW_NAMESPACES_MSG =
          'Do not add new global models in `app/models`. ' \
          'Instead add new models to Rails Engines.'

        def investigate(processed_source)
          return if processed_source.blank?

          path = processed_source.file_path
          return unless global_rails_model?(path)

          add_offense(processed_source.ast)
        end

        private

        def message(_node)
          return ALLOW_NAMESPACES_MSG if allow_namespaced_global_models

          DISALLOW_NAMESPACES_MSG
        end

        def global_rails_model?(path)
          return false unless path.include?(global_models_path)
          return false if path.include?('/concerns/')
          return false if in_engine?(path)
          return false if allowed_namespace?(path)

          true
        end

        def allowed_namespace?(path)
          return false unless allow_namespaced_global_models

          parts = path.split(global_models_path)
          parts.last.split('/').length > 1
        end

        def in_engine?(path)
          return true if path.include?('/engines/')

          # Engines model dirs are structured like:
          #   my_engine/app/models/my_engine/my_model.rb.
          # We detect models whose directory structure matches
          # this pattern even if they aren't children of an
          # "/engines/" directory.
          parts = path.split(global_models_path)
          potential_engine_name = parts.last.split('/').first
          engine_models_path = File.join(
            potential_engine_name,
            global_models_path,
            potential_engine_name
          )
          path.include?(engine_models_path)
        end

        def global_models_path
          path = cop_config['GlobalModelsPath']
          path += '/' unless path.end_with?('/')
          path
        end

        def allow_namespaced_global_models
          cop_config['AllowNamespacedGlobalModels']
        end
      end
    end
  end
end
