# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop prevents code outside of a Rails Engine from directly
      # accessing the engine without going through an API. The goal is
      # to improve modularity and enforce separation of concerns.
      #
      # # Defining an engine's API
      #
      # The cop looks inside an engine's `api/` directory to determine its
      # API. API surface can be defined in two ways:
      #
      # - Add source files to `api/`. Code defined in these modules
      #   will be accessible outside your engine. For example, adding
      #   `api/foo_service.rb` will allow code outside your engine to
      #   invoke eg `MyEngine::Api::FooService.bar(baz)`.
      # - Create a `_whitelist.rb` file in `api/`. Modules listed in
      #   this file are accessible to code outside the engine. The file
      #   must have this name and a particular format (see below).
      #
      # Both of these approaches can be used concurrently in the same engine.
      # Due to Rails Engine directory conventions, the API directory should
      # generally be located at eg `engines/my_engine/app/api/my_engine/api/`.
      #
      # # Usage
      #
      # This cop can be useful when splitting apart a legacy codebase.
      # In particular, you might move some code into an engine without
      # enabling the cop, and then enable the cop to see where the engine
      # boundary is crossed. For each violation, you can either:
      #
      # - Expose new API surface from your engine
      # - Move the violating file into the engine
      # - Add the violating file to `_legacy_dependents.rb` (see below)
      #
      # The cop detects cross-engine associations as well as cross-engine
      # module access.
      #
      # # Isolation guarantee
      #
      # This cop can be easily circumvented with metaprogramming, so it cannot
      # strongly guarantee the isolation of engines. But it can serve as
      # a useful guardrail during development, especially during incremental
      # migrations.
      #
      # Consider using plain-old Ruby objects instead of ActiveRecords as the
      # exchange value between engines. If one engine gets a reference to an
      # ActiveRecord object for a model in another engine, it will be able
      # to perform arbitrary reads and writes via associations and `.save`.
      #
      # # Example `api/_legacy_dependents.rb` file
      #
      # This file contains a burn-down list of source code files that still
      # do direct access to an engine "under the hood", without using the
      # API. It must have this structure.
      #
      # ```rb
      # module MyEngine::Api::LegacyDependents
      #   FILES_WITH_DIRECT_ACCESS = [
      #     "app/models/some_old_legacy_model.rb",
      #     "engines/other_engine/app/services/other_engine/other_service.rb",
      #   ]
      # end
      # ```
      #
      # # Example `api/_whitelist.rb` file
      #
      # This file contains a list of modules that are allowed to be accessed
      # by code outside the engine. It must have this structure.
      #
      # ```rb
      # module MyEngine::Api::Whitelist
      #   PUBLIC_MODULES = [
      #     MyEngine::BarService,
      #     MyEngine::BazService,
      #     MyEngine::BatConstants,
      #   ]
      # end
      # ```
      #
      # @example
      #
      #   # bad
      #   class MyService
      #     m = ReallyImportantSharedEngine::InternalModel.find(123)
      #     m.destroy
      #   end
      #
      #   # good
      #   class MyService
      #     ReallyImportantSharedEngine::Api::SomeService.execute(123)
      #   end
      #
      # @example
      #
      #   # bad
      #
      #   class MyEngine::MyModel < ApplicationModel
      #     has_one :foo_model, class_name: "SharedEngine::FooModel"
      #   end
      #
      #   # good
      #
      #   class MyEngine::MyModel < ApplicationModel
      #     # (No direct associations to models in API-protected engines.)
      #   end
      #
      class EngineApiViolation < Cop
        include EngineApi

        MSG = 'Direct access of %<engine>s engine. ' \
              'Only access engine via %<engine>s::Api.'

        def_node_matcher :rails_association_hash_args, <<-PATTERN
          (send _ {:belongs_to :has_one :has_many} sym $hash)
        PATTERN

        def on_const(node)
          # Sometimes modules/class are declared with the same name as an
          # engine. For example, you might have:
          #
          #   /engines/foo
          #   /app/graph/types/foo
          #
          # We ignore instead of yielding false positive for the module
          # declaration in the latter.
          return if in_module_or_class_declaration?(node)
          # Similarly, you might have value objects that are named
          # the same as engines like:
          #
          # Warehouse.new
          #
          # We don't want to warn on these cases either.
          return if sending_method_to_namespace_itself?(node)

          engine = extract_engine(node)
          return unless engine
          return if valid_engine_access?(node, engine)

          add_offense(node, message: format(MSG, engine: engine))
        end

        def on_send(node)
          rails_association_hash_args(node) do |assocation_hash_args|
            class_name_node = extract_class_name_node(assocation_hash_args)
            next if class_name_node.nil?

            engine = extract_model_engine(class_name_node)
            next if engine.nil?
            next if valid_engine_access?(node, engine)

            add_offense(class_name_node, message: format(MSG, engine: engine))
          end
        end

        def external_dependency_checksum
          engine_api_files_modified_time_checksum(engines_path)
        end

        private

        def extract_engine(node)
          return nil unless protected_engines.include?(node.const_name)

          node.const_name
        end

        def engines_path
          path = cop_config['EnginesPath']
          path += '/' unless path.end_with?('/')
          path
        end

        def protected_engines
          @protected_engines ||= begin
            unprotected = cop_config['UnprotectedEngines'] || []
            unprotected_camelized = camelize_all(unprotected)
            all_engines_camelized - unprotected_camelized
          end
        end

        def all_engines_camelized
          all_snake_case = Dir["#{engines_path}*"].map do |e|
            e.gsub(engines_path, '')
          end
          camelize_all(all_snake_case)
        end

        def camelize_all(names)
          names.map { |n| ActiveSupport::Inflector.camelize(n) }
        end

        def in_module_or_class_declaration?(node)
          depth = 0
          max_depth = 10
          while node.const_type? && depth < max_depth
            node = node.parent
            depth += 1
          end
          node.module_type? || node.class_type?
        end

        def sending_method_to_namespace_itself?(node)
          node.parent.send_type?
        end

        def valid_engine_access?(node, engine)
          (
            in_engine_file?(engine) ||
            in_legacy_dependent_file?(engine) ||
            through_api?(node) ||
            whitelisted?(node, engine)
          )
        end

        def extract_model_engine(class_name_node)
          class_name = class_name_node.value
          prefix = class_name.split('::')[0]
          is_engine_model = prefix && protected_engines.include?(prefix)
          is_engine_model ? prefix : nil
        end

        def extract_class_name_node(assocation_hash_args)
          return nil unless assocation_hash_args

          assocation_hash_args.each_pair do |key, value|
            # Note: The "value.str_type?" is necessary because you can do this:
            #
            # TYPE_CLIENT = "Client".freeze
            # belongs_to :recipient, class_name: TYPE_CLIENT
            #
            # The cop just ignores these cases. We could try to resolve the
            # value of the const from the source but that seems brittle.
            return value if key.value == :class_name && value.str_type?
          end
          nil
        end

        def file_engine
          @file_engine ||= begin
            file_path = processed_source.path
            if file_path&.include?(engines_path)
              parts = file_path.split(engines_path)
              engine_dir = parts.last.split('/').first
              ActiveSupport::Inflector.camelize(engine_dir) if engine_dir
            end
          end
        end

        def in_engine_file?(engine)
          file_engine == engine
        end

        def in_legacy_dependent_file?(engine)
          legacy_dependents = read_api_file(engine, :legacy_dependents)
          # The file names are strings so we need to remove the escaped quotes
          # on either side from the source code.
          legacy_dependents = legacy_dependents.map do |source|
            source.delete('"')
          end
          legacy_dependents.any? do |legacy_dependent|
            processed_source.path.include?(legacy_dependent)
          end
        end

        def through_api?(node)
          node.parent&.const_type? && node.parent.children.last == :Api
        end

        def whitelisted?(node, engine)
          whitelist = read_api_file(engine, :whitelist)
          return false if whitelist.empty?

          depth = 0
          max_depth = 5
          while node.const_type? && depth < max_depth
            full_const_name = remove_leading_colons(node.source)
            return true if whitelist.include?(full_const_name)

            node = node.parent
            depth += 1
          end

          false
        end

        def remove_leading_colons(str)
          str.sub(/^:*/, '')
        end

        def read_api_file(engine, file_basename)
          extract_api_list(engines_path, engine, file_basename)
        end
      end
    end
  end
end
