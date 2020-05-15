# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::BeforeDestroy do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using `#bad_method`' do
    expect_offense(<<~RUBY)
      class MyRecord < ApplicationRecord
        has_many :entities, dependent: :destroy
        before_destroy { do_something }
        ^^^^^^^^^^^^^^ TEST TEST
      end
    RUBY
  end

  xit 'does not register an offense when using `#good_method`' do
    expect_no_offenses(<<~RUBY)
      before_destroy { do_something }
      has_many :entities, dependent: :destroy
    RUBY
  end
end
