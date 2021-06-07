# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::I18nLocaleAssignment, :config do
  it 'registers an offense for `I18n.locale=`' do
    expect_offense(<<~RUBY)
      I18n.locale = :fr
      ^^^^^^^^^^^^^^^^^ Use `I18n.with_locale` with block instead of `I18n.locale=`.
    RUBY
  end

  it 'registers an offense for `::I18n.locale=`' do
    expect_offense(<<~RUBY)
      ::I18n.locale = :fr
      ^^^^^^^^^^^^^^^^^^^ Use `I18n.with_locale` with block instead of `I18n.locale=`.
    RUBY
  end

  it 'accepts `I18n.with_locale`' do
    expect_no_offenses(<<~RUBY)
      I18n.with_locale(:fr) do
        do_something
      end
    RUBY
  end
end
