# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::SpecificActionNames, :config do
  context 'when non configured name is used for private method' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class UsersController < ApplicationController
          private

          def articles
          end
        end
      RUBY
    end
  end

  context 'when configured name is used for public method' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class UsersController < ApplicationController
          def index
          end
        end
      RUBY
    end
  end

  context 'when manually configured name is used for public method' do
    let(:cop_config) do
      { 'ActionNames' => %w[articles] }
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class UsersController < ApplicationController
          def articles
          end
        end
      RUBY
    end
  end

  context 'when non configured name is used for public method' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class UsersController < ApplicationController
          def articles
              ^^^^^^^^ Use only specific action names (index, show, new, edit, create, update, destroy).
          end
        end
      RUBY
    end
  end

  context 'when non configured name is used for public method in a concern module' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module UsersConcern
          def articles
              ^^^^^^^^ Use only specific action names (index, show, new, edit, create, update, destroy).
          end
        end
      RUBY
    end
  end
end
