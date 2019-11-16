# frozen_string_literal: true

require 'active_support/inflector'
require 'digest/sha1'

module RuboCop
  module Cop
    module Rails
      # This cop checks for engines reaching directly into app/ models.
      #
      # With an ActiveRecord object, engine code can perform arbitrary
      # reads and arbitrary writes to models located in the main `app/`
      # directory. This cop helps isolate Rails Engine code to ensure
      # that modular boundaries are respected.
      #
      # Checks for both access via `MyGlobalModel.foo` and associations.
      #
      # @example
      #
      #   # bad
      #
      #   class MyEngine::MyService
      #     m = SomeGlobalModel.find(123)
      #     m.any_random_attribute = "whatever i want"
      #     m.save
      #   end
      #
      #   # good
      #
      #   class MyEngine::MyService
      #     ApiServiceForGlobalModels.perform_a_supported_operation("foo")
      #   end
      #
      # @example
      #
      #   # bad
      #
      #   class MyEngine::MyModel < ApplicationModel
      #     has_one :some_global_model, class_name: "SomeGlobalModel"
      #   end
      #
      #   # good
      #
      #   class MyEngine::MyModel < ApplicationModel
      #     # No direct association to global models.
      #   end
      #
      class EngineGlobalModelAccess < Cop
        MSG = 'Direct access of global model from within Rails Engine.'

        def_node_matcher :rails_association_hash_args, <<-PATTERN
          (send _ {:belongs_to :has_one :has_many} sym $hash)
        PATTERN

        def on_const(node)
          return unless in_enforced_engine_file?
          return unless global_model_const?(node)
          # The cop allows access to e.g. MyGlobalModel::MY_CONST.
          return if child_of_const?(node)

          add_offense(node)
        end

        def on_send(node)
          return unless in_enforced_engine_file?

          rails_association_hash_args(node) do |assocation_hash_args|
            class_name_node = extract_class_name_node(assocation_hash_args)
            class_name = class_name_node&.value
            next unless global_model?(class_name)

            add_offense(class_name_node)
          end
        end

        # Because this cop's behavior depends on the state of external files,
        # we override this method to bust the RuboCop cache when those files
        # change.
        def external_dependency_checksum
          Digest::SHA1.hexdigest(model_dir_paths.join)
        end

        private

        def global_model_names
          @global_model_names ||= calculate_global_models
        end

        def model_dir_paths
          Dir[File.join(global_models_path, '**/*.rb')]
        end

        def calculate_global_models
          all_model_paths = model_dir_paths.reject do |path|
            path.include?('/concerns/')
          end
          all_models = all_model_paths.map do |path|
            # Translates `app/models/foo/bar_baz.rb` to `Foo::BarBaz`.
            file_name = path.gsub(global_models_path, '').gsub('.rb', '')
            ActiveSupport::Inflector.classify(file_name)
          end
          all_models - allowed_global_models
        end

        def extract_class_name_node(assocation_hash_args)
          assocation_hash_args.each_pair do |key, value|
            return value if key.value == :class_name && value.str_type?
          end
          nil
        end

        def in_enforced_engine_file?
          file_path = processed_source.path
          return false unless file_path.include?(engines_path)
          return false if in_disabled_engine?(file_path)

          true
        end

        def in_disabled_engine?(file_path)
          disabled_engines.any? do |e|
            file_path.include?(File.join(engines_path, e))
          end
        end

        def global_model_const?(const_node)
          # Remove leading `::`, if any.
          class_name = const_node.source.sub(/^:*/, '')
          global_model?(class_name)
        end

        # class_name is e.g. "FooGlobalModelNamespace::BarModel"
        def global_model?(class_name)
          global_model_names.include?(class_name)
        end

        def child_of_const?(node)
          node.parent.const_type?
        end

        def global_models_path
          path = cop_config['GlobalModelsPath']
          path += '/' unless path.end_with?('/')
          path
        end

        def engines_path
          cop_config['EnginesPath']
        end

        def disabled_engines
          raw = cop_config['DisabledEngines'] || []
          raw.map do |e|
            ActiveSupport::Inflector.underscore(e)
          end
        end

        def allowed_global_models
          cop_config['AllowedGlobalModels'] || []
        end
      end
    end
  end
end
