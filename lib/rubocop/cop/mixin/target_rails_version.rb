# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking target rails version.
    module TargetRailsVersion
      # Informs the base RuboCop gem that it the Rails version is checked via `requires_gem` API,
      # without needing to call this `#support_target_rails_version` method.
      USES_REQUIRES_GEM_API = true
      # Look for `railties` instead of `rails`, to support apps that only use a subset of `rails`
      # See https://github.com/rubocop/rubocop/pull/11289
      TARGET_GEM_NAME = 'railties' # :nodoc:

      # Used when the target Rails version cannot be detected from `AllCops: TargetRailsVersion`
      # or from the `railties` version in the target's lockfile.
      DEFAULT_RAILS_VERSION = 5.0

      # Resolves the target Rails version as a `major.minor` Float, using only stable RuboCop core APIs.
      # Precedence: `AllCops: TargetRailsVersion`, then the `railties` version from the target's lockfile,
      # then `DEFAULT_RAILS_VERSION`.
      def self.resolve(config)
        target_rails_version = config.for_all_cops['TargetRailsVersion']
        return target_rails_version.to_f if target_rails_version

        gem_versions_in_target = config.gem_versions_in_target
        railties_version = gem_versions_in_target && gem_versions_in_target[TARGET_GEM_NAME]
        return DEFAULT_RAILS_VERSION unless railties_version

        segments = railties_version.segments
        Float("#{segments[0]}.#{segments[1]}")
      end

      def self.extended(base)
        base.include(InstanceMethods)
      end

      def minimum_target_rails_version(version)
        case version
        when Integer, Float then requires_gem(TARGET_GEM_NAME, ">= #{version}")
        when String then requires_gem(TARGET_GEM_NAME, version)
        end
      end

      def support_target_rails_version?(version)
        return false unless gem_requirements

        gem_requirement = gem_requirements[TARGET_GEM_NAME]
        return true unless gem_requirement # If we have no requirement, then we support all versions

        gem_requirement.satisfied_by?(Gem::Version.new(version))
      end

      # Instance methods for cops that use the resolved target Rails version at runtime,
      # included automatically when a cop extends `TargetRailsVersion`.
      # On RuboCop < 2.0, `#target_rails_version` shadows `RuboCop::Cop::Base#target_rails_version`,
      # so the resolution is owned by rubocop-rails on all supported RuboCop versions.
      module InstanceMethods
        def target_rails_version
          @target_rails_version ||= TargetRailsVersion.resolve(config)
        end
      end
    end
  end
end
