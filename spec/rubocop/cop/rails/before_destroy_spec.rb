# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::BeforeDestroy do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  ASSOCIATION_METHODS = %i[has_many has_one belongs_to]
  ASSOCIATION_METHODS.each do |association_method|
    context "#{association_method} precedes before_destroy" do
      it "registers an offense if #{association_method} has dependent destroy" do
        expect_offense(<<~RUBY)
          class MyRecord < ApplicationRecord
            #{association_method} :entities, dependent: :destroy
            before_destroy { do_something }
            ^^^^^^^^^^^^^^ "before_destroy" callbacks must run before "dependent: :destroy" associations.
          end
        RUBY
      end

      it "does not register an offense if before_destroy with block has prepend: true" do
        expect_no_offenses(<<~RUBY)
          class MyRecord < ApplicationRecord
            #{association_method} :entities, dependent: :destroy
            before_destroy(prepend: true) { do_something }
          end
        RUBY
      end

      it "does not register an offense if before_destroy with method reference has prepend: true" do
        expect_no_offenses(<<~RUBY)
          class MyRecord < ApplicationRecord
            #{association_method} :entities, dependent: :destroy
            before_destroy :some_method, prepend: true
          end
        RUBY
      end

      it "does not register an offense if #{association_method} is not dependent destroy" do
        expect_no_offenses(<<~RUBY)
          class MyRecord < ApplicationRecord
            #{association_method} :entities
            before_destroy { do_something }
          end
        RUBY
      end
    end

    context "before_destroy precedes #{association_method} with dependent: :destroy" do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class MyRecord < ApplicationRecord
            before_destroy { do_something }
            #{association_method} :entities, dependent: :destroy
          end
        RUBY
      end
    end
  end
end
