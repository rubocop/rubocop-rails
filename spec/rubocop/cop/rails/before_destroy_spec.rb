# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::BeforeDestroy do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'association precedes before_destroy' do
    it 'registers an offense if the association has dependent destroy' do
      expect_offense(<<~RUBY)
        class MyRecord < ApplicationRecord
          has_many :entities, dependent: :destroy
          before_destroy { do_something }
          ^^^^^^^^^^^^^^ TEST TEST
        end
      RUBY
    end

    it 'does not register an offense if the dependent destroy association has prepend true' do
      expect_no_offenses(<<~RUBY)
        class MyRecord < ApplicationRecord
          has_many :entities, prepend: true, dependent: :destroy
          before_destroy { do_something }
        end
      RUBY
    end

    it 'does not register an offense if the association is not dependent destroy' do
      expect_no_offenses(<<~RUBY)
        class MyRecord < ApplicationRecord
          has_many :entities
          before_destroy { do_something }
        end
      RUBY
    end
  end

  context 'before_destroy precedes association' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyRecord < ApplicationRecord
          before_destroy { do_something }
          has_many :entities, dependent: :destroy
        end
      RUBY
    end
  end
end
