# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EnvLocal, :config do
  shared_examples 'non-local candidates' do
    it 'registers no offenses for non-local `Rails.env._? || Rails.env._?`' do
      expect_no_offenses(<<~RUBY)
        Rails.env.development? || Rails.env.production?
        Rails.env.test? || Rails.env.production?
        Rails.env.production? || Rails.env.other?
      RUBY
    end

    it 'registers no offenses for non-local `!Rails.env._? && !Rails.env._?`' do
      expect_no_offenses(<<~RUBY)
        !Rails.env.development? && Rails.env.production?
        !Rails.env.test? && Rails.env.production?
        !Rails.env.production? && Rails.env.other?
      RUBY
    end

    it 'registers no offenses for single `Rails.env._?`' do
      expect_no_offenses(<<~RUBY)
        Rails.env.development?
        Rails.env.test?
        Rails.env.production?
        Rails.env.other?
      RUBY
    end
  end

  context 'In Rails >= 7.1', :rails71 do
    it 'registers an offense for `Rails.env.development? || Rails.env.test?`' do
      expect_offense(<<~RUBY)
        Rails.env.development? || Rails.env.test?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.env.local?` instead.
        Rails.env.test? || Rails.env.development?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.env.local?` instead.
      RUBY

      expect_correction(<<~RUBY)
        Rails.env.local?
        Rails.env.local?
      RUBY
    end

    it 'registers an offense for `Rails.env.development? || Rails.env.test?` || foo?' do
      expect_offense(<<~RUBY)
        Rails.env.development? || Rails.env.test? || foo?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.env.local?` instead.
        foo? || Rails.env.test? || Rails.env.development?
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rails.env.local?` instead.
      RUBY

      expect_correction(<<~RUBY)
        Rails.env.local? || foo?
        foo? || Rails.env.local?
      RUBY
    end

    it 'registers an offense for `!Rails.env.development? && !Rails.env.test?`' do
      expect_offense(<<~RUBY)
        !Rails.env.development? && !Rails.env.test?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!Rails.env.local?` instead.
        !Rails.env.test? && !Rails.env.development?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!Rails.env.local?` instead.
      RUBY

      expect_correction(<<~RUBY)
        !Rails.env.local?
        !Rails.env.local?
      RUBY
    end

    it 'registers an offense for `!Rails.env.development? && !Rails.env.test?` || foo?' do
      expect_offense(<<~RUBY)
        !Rails.env.development? && !Rails.env.test? || foo?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!Rails.env.local?` instead.
        foo? || !Rails.env.test? && !Rails.env.development?
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!Rails.env.local?` instead.
      RUBY

      expect_correction(<<~RUBY)
        !Rails.env.local? || foo?
        foo? || !Rails.env.local?
      RUBY
    end

    it 'registers an offense for `!Rails.env.development? && !Rails.env.test?` && foo?' do
      expect_offense(<<~RUBY)
        !Rails.env.development? && !Rails.env.test? && foo?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!Rails.env.local?` instead.
        foo? && !Rails.env.test? && !Rails.env.development?
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!Rails.env.local?` instead.
      RUBY

      expect_correction(<<~RUBY)
        !Rails.env.local? && foo?
        foo? && !Rails.env.local?
      RUBY
    end

    it 'registers no offenses for `Rails.env.local?`' do
      expect_no_offenses(<<~RUBY)
        Rails.env.local?
      RUBY
    end

    it 'registers no offenses for `Rails.env.development? || Rails.env.test? && foo?`' do
      expect_no_offenses(<<~RUBY)
        Rails.env.development? || Rails.env.test? && foo?
      RUBY
    end

    it_behaves_like 'non-local candidates'
  end

  context 'In Rails < 7.1', :rails70 do
    it 'registers no offenses for `Rails.env.development? || Rails.env.test?`' do
      expect_no_offenses(<<~RUBY)
        Rails.env.development? || Rails.env.test?
        Rails.env.test? || Rails.env.development?
      RUBY
    end

    it 'registers no offenses for `!Rails.env.development? && !Rails.env.test?`' do
      expect_no_offenses(<<~RUBY)
        !Rails.env.development? && !Rails.env.test?
        !Rails.env.test? && !Rails.env.development?
      RUBY
    end

    it 'registers no offenses for `Rails.env.local?`' do
      expect_no_offenses(<<~RUBY)
        Rails.env.local?
      RUBY
    end

    it_behaves_like 'non-local candidates'
  end
end
