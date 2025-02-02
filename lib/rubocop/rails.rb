# frozen_string_literal: true

module RuboCop
  # RuboCop Rails project namespace
  module Rails
    PROJECT_ROOT   = Pathname.new(__dir__).parent.parent.expand_path.freeze
    CONFIG_DEFAULT = PROJECT_ROOT.join('config', 'default.yml').freeze

    private_constant(:CONFIG_DEFAULT, :PROJECT_ROOT)

    ConfigObsoletion.files << Pathname("#{__dir__}/../../config/obsoletion.yml")
  end
end
