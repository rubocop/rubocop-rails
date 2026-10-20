# frozen_string_literal: true

module RuboCop
  module Cop
    module RelativeIncludeMatching
      def relevant_file?(file)
        return false unless super

        include_patterns = cop_config['Include']
        return true unless include_patterns

        relative_path = config.path_relative_to_config(file)
        RuboCop::FilePatterns.from(include_patterns).match?(relative_path)
      end
    end
  end
end
