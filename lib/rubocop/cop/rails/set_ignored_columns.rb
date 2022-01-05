# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cops looks for assignments of `ignored_columns` that may override previous
      # assignments.
      #
      # Overwriting previous assignments is usually a mistake, since it will
      # un-ignore the first set of columns. Since duplicate column names is not
      # a problem, it is better to simply append to the list.
      #
      # @example
      #
      #   # bad
      #   class User < ActiveRecord::Base
      #     self.ignored_columns = [:one]
      #   end
      #
      #   # bad
      #   class User < ActiveRecord::Base
      #     self.ignored_columns = [:one, :two]
      #   end
      #
      #   # good
      #   class User < ActiveRecord::Base
      #     self.ignored_columns += [:one, :two]
      #   end
      #
      #   # good
      #   class User < ActiveRecord::Base
      #     self.ignored_columns += [:one]
      #     self.ignored_columns += [:two]
      #   end
      #
      class SetIgnoredColumns < Base
        extend AutoCorrector
        MSG = 'This assignment to `ignored_columns` may overwrite previous ones.'

        RESTRICT_ON_SEND = %i[ignored_columns=].freeze

        def on_send(node)
          add_offense(node) do |corrector|
            corrector.replace(node.loc.operator, '+=')
          end
        end
      end
    end
  end
end
