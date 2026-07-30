# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::IncludeViewHelper, :config do
  it 'registers an offense when including a helper module in a controller' do
    expect_offense(<<~RUBY)
      class UsersController < ApplicationController
        include UserHelper
        ^^^^^^^^^^^^^^^^^^ Do not include view helpers outside of the view context. Use a concern or the `helpers` proxy instead.
      end
    RUBY
  end

  it 'registers an offense when including a helper module in a model' do
    expect_offense(<<~RUBY)
      class User < ApplicationRecord
        include ApplicationHelper
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not include view helpers outside of the view context. Use a concern or the `helpers` proxy instead.
      end
    RUBY
  end

  it 'registers an offense when including a namespaced helper module' do
    expect_offense(<<~RUBY)
      class ReportsController < ApplicationController
        include Reports::FormattingHelper
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not include view helpers outside of the view context. Use a concern or the `helpers` proxy instead.
      end
    RUBY
  end

  it 'registers an offense when including an ActionView::Helpers module' do
    expect_offense(<<~RUBY)
      class MyJob < ApplicationJob
        include ActionView::Helpers::NumberHelper
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not include view helpers outside of the view context. Use a concern or the `helpers` proxy instead.
      end
    RUBY
  end

  it 'does not register an offense when including a non-helper module' do
    expect_no_offenses(<<~RUBY)
      class User < ApplicationRecord
        include Comparable
      end
    RUBY
  end

  it 'does not register an offense when including an ActiveSupport concern' do
    expect_no_offenses(<<~RUBY)
      class User < ApplicationRecord
        include ActiveSupport::Concern
      end
    RUBY
  end

  it 'registers an offense when a helper is among multiple included modules' do
    expect_offense(<<~RUBY)
      class UsersController < ApplicationController
        include UserHelper, Searchable
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not include view helpers outside of the view context. Use a concern or the `helpers` proxy instead.
      end
    RUBY
  end

  it 'registers an offense when an ActionView helper is among multiple included modules' do
    expect_offense(<<~RUBY)
      class MyJob < ApplicationJob
        include Searchable, ActionView::Helpers::NumberHelper
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not include view helpers outside of the view context. Use a concern or the `helpers` proxy instead.
      end
    RUBY
  end
end
