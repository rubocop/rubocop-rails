# frozen_string_literal: true

require 'rubocop-rails'

module RuboCop
  module Cop
    module Rails
      # Checks that policies subclass `ApplicationPolicy`.
      #
      # @safety
      #   This cop's autocorrection is unsafe because it may let the logic from `ApplicationPolicy`
      #   sneak into a policy that is not purposed to inherit logic common among other policies.
      #
      # @example
      #
      #  # good
      #  class MyPolicy < ApplicationPolicy
      #    # ...
      #  end
      #
      #  # bad
      #  class MyPolicy < ActionPolicy::Base
      #    # ...
      #  end
      class ApplicationPolicy < Base
        extend AutoCorrector

        include RuboCop::Cop::EnforceSuperclass
        MSG = 'Policies should subclass `ApplicationPolicy`.'
        SUPERCLASS = 'ApplicationPolicy'
        BASE_PATTERN = '(const (const nil? :ActionPolicy) :Base)'
      end
    end
  end
end
