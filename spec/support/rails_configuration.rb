# frozen_string_literal: true

# Provides the Rails-specific configuration plumbing for cop specs, replacing the plumbing that
# RuboCop core's `rubocop/rspec/support` provides until RuboCop 2.0.
#
# Registration order matters: this context must be registered after RuboCop core's 'config' shared context
# (so its `let` definitions win) and before the 'with Rails N.N' contexts in `shared_contexts.rb`
# (so their `rails_version` wins).
RSpec.shared_context 'rails configuration' do
  let(:rails_version) { nil }

  let(:all_cops_config) do
    all_cops = { 'TargetRubyVersion' => ruby_version }
    all_cops['TargetRailsVersion'] = rails_version if rails_version
    all_cops
  end

  # Keeps `railties` in the `gem_versions_in_target` stub so that cops gated by `minimum_target_rails_version`
  # stay enabled in specs once RuboCop core stops stubbing `railties` itself.
  let(:gem_versions) do
    { 'railties' => (rails_version || RuboCop::Cop::TargetRailsVersion::DEFAULT_RAILS_VERSION).to_s }
  end
end

RSpec.configure do |config|
  config.include_context 'rails configuration', :config
end
