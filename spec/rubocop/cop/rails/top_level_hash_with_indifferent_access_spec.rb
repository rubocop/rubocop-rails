# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TopLevelHashWithIndifferentAccess, :config, :rails51 do
  context 'with top-level HashWithIndifferentAccess' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        HashWithIndifferentAccess.new(foo: 'bar')
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid top-level `HashWithIndifferentAccess`.
      RUBY

      expect_correction(<<~RUBY)
        ActiveSupport::HashWithIndifferentAccess.new(foo: 'bar')
      RUBY
    end
  end

  context 'with top-level ::HashWithIndifferentAccess' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        ::HashWithIndifferentAccess.new(foo: 'bar')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid top-level `HashWithIndifferentAccess`.
      RUBY

      expect_correction(<<~RUBY)
        ::ActiveSupport::HashWithIndifferentAccess.new(foo: 'bar')
      RUBY
    end
  end

  context 'with top-level `HashWithIndifferentAccess` without method call' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        HashWithIndifferentAccess
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid top-level `HashWithIndifferentAccess`.
      RUBY

      expect_correction(<<~RUBY)
        ActiveSupport::HashWithIndifferentAccess
      RUBY
    end
  end

  context 'with ActiveSupport::HashWithIndifferentAccess' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        ActiveSupport::HashWithIndifferentAccess.new(foo: 'bar')
      RUBY
    end
  end

  context 'with `HashWithIndifferentAccess` under the namespace' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module CoreExt
          class HashWithIndifferentAccess
          end
        end
      RUBY
    end
  end

  context 'with ActiveSupport::HashWithIndifferentAccess on Rails 5.0', :rails50 do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        HashWithIndifferentAccess.new(foo: 'bar')
      RUBY
    end
  end
end
