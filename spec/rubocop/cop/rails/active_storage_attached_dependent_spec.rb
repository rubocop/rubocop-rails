# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActiveStorageAttachedDependent, :config do
  it 'flags has_one_attached dependent: true' do
    expect_offense(<<~RUBY)
      class Foo
        has_one_attached :bar, dependent: true
                               ^^^^^^^^^^^^^^^ `dependent: true` is silently a no-op in ActiveStorage and leaves orphan blobs in storage. Use `:purge_later` (default) or `false`.
      end
    RUBY
  end

  it 'flags has_one_attached when dependent: nil' do
    expect_offense(<<~RUBY)
      class Foo
        has_one_attached :bar, dependent: nil
                               ^^^^^^^^^^^^^^ `dependent: nil` is silently a no-op in ActiveStorage and leaves orphan blobs in storage. Use `:purge_later` (default) or `false`.
      end
    RUBY
  end

  it 'flags has_one_attached when dependent: :purge at warning severity (cites rails/rails#36423)' do
    expect_offense(<<~RUBY, severity: :warning)
      class Foo
        has_one_attached :bar, dependent: :purge
                               ^^^^^^^^^^^^^^^^^ `dependent: :purge` is documented but only `:purge_later` is honored by ActiveStorage today (rails/rails#36423). Use `:purge_later` (default).
      end
    RUBY
  end

  it 'flags has_one_attached when dependent: is an arbitrary unrecognized symbol' do
    expect_offense(<<~RUBY)
      class Foo
        has_one_attached :bar, dependent: :nope
                               ^^^^^^^^^^^^^^^^ `dependent: :nope` is silently a no-op in ActiveStorage and leaves orphan blobs in storage. Use `:purge_later` (default) or `false`.
      end
    RUBY
  end

  it 'flags has_many_attached dependent: true' do
    expect_offense(<<~RUBY)
      class Foo
        has_many_attached :bars, dependent: true
                                 ^^^^^^^^^^^^^^^ `dependent: true` is silently a no-op in ActiveStorage and leaves orphan blobs in storage. Use `:purge_later` (default) or `false`.
      end
    RUBY
  end

  it 'allows documented dependent values' do
    [':purge_later', 'false'].each do |value|
      expect_no_offenses(<<~RUBY)
        class Foo
          has_one_attached :bar, dependent: #{value}
        end
      RUBY
    end
  end

  it 'allows has_one_attached without a dependent: argument' do
    expect_no_offenses(<<~RUBY)
      class Foo
        has_one_attached :bar
      end
    RUBY
  end
end
