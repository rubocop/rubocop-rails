# frozen_string_literal: true

module RuboCop
  module Cop
    # Autoloads mixin modules included by cops. Mixins are autoloaded to reduce the number of requires
    # because they're used only when the relevant cop class is loaded.
    autoload :ActiveRecordHelper, "#{__dir__}/mixin/active_record_helper"
    autoload :ActiveRecordMigrationsHelper, "#{__dir__}/mixin/active_record_migrations_helper"
    autoload :ClassSendNodeHelper, "#{__dir__}/mixin/class_send_node_helper"
    autoload :DatabaseTypeResolvable, "#{__dir__}/mixin/database_type_resolvable"
    autoload :EnforceSuperclass, "#{__dir__}/mixin/enforce_superclass"
    autoload :IndexMethod, "#{__dir__}/mixin/index_method"
    autoload :MigrationsHelper, "#{__dir__}/mixin/migrations_helper"
    autoload :RoutesHelper, "#{__dir__}/mixin/routes_helper"
    autoload :TargetRailsVersion, "#{__dir__}/mixin/target_rails_version"
  end
end
