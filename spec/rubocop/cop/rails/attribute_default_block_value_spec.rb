# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::AttributeDefaultBlockValue, :config do
  let(:message) { 'Pass method in a block to `:default` option.' }

  context 'when `:default` option is last' do
    it 'disallows method' do
      expect_offense(<<~RUBY)
        def bar
        end

        attribute :foo, :string, default: bar
                                          ^^^ #{message}
      RUBY
    end

    it 'disallows method called from other instance object' do
      expect_offense(<<~RUBY)
        attribute :foo, :string, default: Foo.new.bar
                                          ^^^^^^^^^^^ #{message}
      RUBY
    end

    it 'disallows array literals' do
      expect_offense(<<~RUBY)
        attribute :foo, :string, array: true, default: []
                                                       ^^ #{message}
      RUBY
    end

    it 'disallows hash literals' do
      expect_offense(<<~RUBY)
        attribute :foo, default: {}
                                 ^^ #{message}
      RUBY
    end

    it 'autocorrects `:default` method value in same row' do
      expect_offense(<<~RUBY)
        attribute :foo, :string, default: Foo.bar
                                          ^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        attribute :foo, :string, default: -> { Foo.bar }
      RUBY
    end

    it 'autocorrects `:default` method value in next row' do
      expect_offense(<<~RUBY)
        attribute :foo, :string, limit: 1,
                                 default: Foo.bar
                                          ^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        attribute :foo, :string, limit: 1,
                                 default: -> { Foo.bar }
      RUBY
    end

    it 'allows boolean false' do
      expect_no_offenses(<<~RUBY)
        attribute :foo, :boolean, default: false
      RUBY
    end

    it 'allows boolean true' do
      expect_no_offenses(<<~RUBY)
        attribute :foo, :boolean, default: true
      RUBY
    end

    it 'allows symbol' do
      expect_no_offenses(<<~RUBY)
        attribute :foo, :string, default: :bar
      RUBY
    end

    it 'allows int' do
      expect_no_offenses(<<~RUBY)
        attribute :foo, :integer, default: 1
      RUBY
    end

    it 'allows decimal' do
      expect_no_offenses(<<~RUBY)
        attribute :foo, :decimal, default: 3.14
      RUBY
    end

    it 'allows constant' do
      expect_no_offenses(<<~RUBY)
        CONSTANT = :foo
        attribute :bar, :string, default: CONSTANT
      RUBY
    end

    it 'allows block' do
      expect_no_offenses(<<~RUBY)
        attribute :foo, :datetime, default: -> { Time.zone.now }
      RUBY
    end

    it 'allows without default value' do
      expect_no_offenses(<<~RUBY)
        attribute :foo, :datetime
      RUBY
    end

    it 'allows with array option' do
      expect_no_offenses(<<~RUBY)
        attribute :foo, :bar, array: FooBar.array
      RUBY
    end

    it 'allows with range option' do
      expect_no_offenses(<<~RUBY)
        attribute :foo, :bar, range: FooBar.range
      RUBY
    end

    it 'allows with limit option' do
      expect_no_offenses(<<~RUBY)
        attribute :foo, :bar, limit: FooBar.limit
      RUBY
    end
  end

  context 'when `:default` option is next to last' do
    it 'disallows `:default` method value' do
      expect_offense(<<~RUBY)
        attribute :foo, :string, range: true, default: Foo.bar, limit: 10
                                                       ^^^^^^^ #{message}
      RUBY
    end

    it 'autocorrects `:default` method value' do
      expect_offense(<<~RUBY)
        attribute :foo, :string, default: Foo.bar, limit: 1
                                          ^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        attribute :foo, :string, default: -> { Foo.bar }, limit: 1
      RUBY
    end
  end
end
