# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::HasAndBelongsToMany, :config do
  it 'registers an offense for has_and_belongs_to_many' do
    expect_offense(<<~RUBY)
      has_and_belongs_to_many :groups
      ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `has_many :through` to `has_and_belongs_to_many`.
    RUBY
  end

  it 'does not register an offense for has_and_belongs_to_many with receiver' do
    expect_no_offenses(<<~RUBY)
      obj.has_and_belongs_to_many :groups
    RUBY
  end
end
