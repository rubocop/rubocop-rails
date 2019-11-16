# frozen_string_literal: true

require 'active_support/inflector'
require 'digest/sha1'

module RuboCop
  module Cop
    # Functionality for reading Rails Engine API declaration files.
    module EngineApi
      extend NodePattern::Macros

      API_FILE_DETAILS = {
        whitelist: {
          file_basename: '_whitelist.rb',
          array_matcher: :whitelist_array
        },
        legacy_dependents: {
          file_basename: '_legacy_dependents.rb',
          array_matcher: :legacy_dependents_array
        }
      }.freeze

      def extract_api_list(engines_path, engine, api_file)
        key = cache_key(engine, api_file)
        @cache ||= {}
        cached = @cache[key]
        return cached if cached

        details = API_FILE_DETAILS[api_file]

        path = full_path(engines_path, engine, details)
        return [] unless File.file?(path)

        list = extract_array(path, details[:array_matcher])

        @cache[key] = list
        list
      end

      def engine_api_files_modified_time_checksum(engines_path)
        api_files = Dir.glob(File.join(engines_path, '**/app/api/**/api/**/*'))
        mtimes = api_files.sort.map { |f| File.mtime(f) }
        Digest::SHA1.hexdigest(mtimes.join)
      end

      private

      def full_path(engines_path, engine, details)
        api_path(engines_path, engine) + details[:file_basename]
      end

      def cache_key(engine, api_file)
        "#{engine}-#{api_file}"
      end

      def api_path(engines_path, engine)
        raw_name = ActiveSupport::Inflector.underscore(engine.to_s)
        File.join(engines_path, "#{raw_name}/app/api/#{raw_name}/api/")
      end

      def parse_ast(file_path)
        source_code = File.read(file_path)
        source = RuboCop::ProcessedSource.new(source_code, RUBY_VERSION.to_f)
        source.ast
      end

      def extract_module_root(path)
        # The AST for the whitelist definition looks like this:
        #
        # (:module,
        #   (:const,
        #     (:const, nil, :Trucking), :Api),
        #   (:casgn, nil, :PUBLIC_SERVICES,
        #     (:array,
        #       (:const,
        #         s(:const, nil, :Trucking), :CancelDeliveryOrderService),
        #       (:const,
        #         s(:const, nil, :Trucking), :FclFulfillmentDetailsService))
        #
        # Or, in the case of two separate whitelists:
        #
        # (:module,
        #   (:const,
        #     (:const, nil, :Trucking), :Api),
        #   s(:begin,
        #     s(:casgn, nil, :PUBLIC_SERVICES,
        #       s(:send,
        #         s(:array,
        #           s(:const,
        #             s(:const, nil, :Trucking), :CancelDeliveryOrderService),
        #           s(:const,
        #             s(:const, nil, :Trucking), :ContainerUseService))),
        #     s(:casgn, nil, :PUBLIC_CONSTANTS,
        #       s(:send,
        #         s(:array,
        #           s(:const,
        #             s(:const, nil, :Trucking), :DeliveryStatuses),
        #           s(:const,
        #             s(:const, nil, :Trucking), :LoadTypes)), :freeze)))
        #
        # We want the :begin in the 2nd case, the :module in the 1st case.
        module_node = parse_ast(path)
        module_block_node = module_node&.children&.[](1)
        if module_block_node&.begin_type?
          module_block_node
        else
          module_node
        end
      end

      def_node_matcher :whitelist_array, <<-PATTERN
          (casgn nil? {:PUBLIC_MODULES :PUBLIC_SERVICES :PUBLIC_CONSTANTS :PUBLIC_TYPES} {$array (send $array ...)})
      PATTERN

      def_node_matcher :legacy_dependents_array, <<-PATTERN
          (casgn nil? {:FILES_WITH_DIRECT_ACCESS} {$array (send $array ...)})
      PATTERN

      def extract_array(path, array_matcher)
        list = []
        root_node = extract_module_root(path)
        root_node.children.each do |module_child|
          array_node = send(array_matcher, module_child)
          next if array_node.nil?

          array_node.children.map do |item|
            list << item.source
          end
        end
        list
      end
    end
  end
end
