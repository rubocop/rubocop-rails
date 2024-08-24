# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Validation, :config do
  described_class::TYPES.each do |type|
    it "registers an offense for with validates_#{type}_of" do
      type = 'length' if type == 'size'
      expect_offense(<<~RUBY, type: type)
        validates_#{type}_of :full_name, :birth_date
        ^^^^^^^^^^^{type}^^^ Prefer the new style validations `validates :column, #{type}: value` over `validates_#{type}_of`.
      RUBY

      expect_correction(<<~RUBY)
        validates :full_name, :birth_date, #{type}: true
      RUBY
    end

    it "registers an offense for with validates_#{type}_of when method arguments are enclosed in parentheses" do
      type = 'length' if type == 'size'
      expect_offense(<<~RUBY, type: type)
        validates_#{type}_of(:full_name, :birth_date)
        ^^^^^^^^^^^{type}^^^ Prefer the new style validations `validates :column, #{type}: value` over `validates_#{type}_of`.
      RUBY

      expect_correction(<<~RUBY)
        validates(:full_name, :birth_date, #{type}: true)
      RUBY
    end

    it "registers an offense for with validates_#{type}_of when attributes are specified with array literal" do
      type = 'length' if type == 'size'
      expect_offense(<<~RUBY, type: type)
        validates_#{type}_of [:full_name, :birth_date]
        ^^^^^^^^^^^{type}^^^ Prefer the new style validations `validates :column, #{type}: value` over `validates_#{type}_of`.
      RUBY

      expect_correction(<<~RUBY)
        validates :full_name, :birth_date, #{type}: true
      RUBY
    end

    it "registers an offense for with validates_#{type}_of when attributes are specified with frozen array literal" do
      type = 'length' if type == 'size'
      expect_offense(<<~RUBY, type: type)
        validates_#{type}_of [:full_name, :birth_date].freeze
        ^^^^^^^^^^^{type}^^^ Prefer the new style validations `validates :column, #{type}: value` over `validates_#{type}_of`.
      RUBY

      expect_correction(<<~RUBY)
        validates :full_name, :birth_date, #{type}: true
      RUBY
    end

    it "registers an offense for with validates_#{type}_of when attributes are specified with symbol array literal" do
      type = 'length' if type == 'size'
      expect_offense(<<~RUBY, type: type)
        validates_#{type}_of %i[full_name birth_date]
        ^^^^^^^^^^^{type}^^^ Prefer the new style validations `validates :column, #{type}: value` over `validates_#{type}_of`.
      RUBY

      expect_correction(<<~RUBY)
        validates :full_name, :birth_date, #{type}: true
      RUBY
    end

    it "registers an offense for with validates_#{type}_of when " \
       'attributes are specified with frozen symbol array literal' do
      type = 'length' if type == 'size'
      expect_offense(<<~RUBY, type: type)
        validates_#{type}_of %i[full_name birth_date].freeze
        ^^^^^^^^^^^{type}^^^ Prefer the new style validations `validates :column, #{type}: value` over `validates_#{type}_of`.
      RUBY

      expect_correction(<<~RUBY)
        validates :full_name, :birth_date, #{type}: true
      RUBY
    end
  end

  it 'registers an offense with single attribute name' do
    expect_offense(<<~RUBY)
      validates_numericality_of :a
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer the new style [...]
    RUBY

    expect_correction(<<~RUBY)
      validates :a, numericality: true
    RUBY
  end

  it 'registers an offense with multi attribute names' do
    expect_offense(<<~RUBY)
      validates_numericality_of :a, :b
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer the new style [...]
    RUBY

    expect_correction(<<~RUBY)
      validates :a, :b, numericality: true
    RUBY
  end

  it 'registers an offense with non-braced hash literal' do
    expect_offense(<<~RUBY)
      validates_numericality_of :a, :b, minimum: 1
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer the new style [...]
    RUBY

    expect_correction(<<~RUBY)
      validates :a, :b, numericality: { minimum: 1 }
    RUBY
  end

  it 'registers an offense with braced hash literal' do
    expect_offense(<<~RUBY)
      validates_numericality_of :a, :b, { minimum: 1 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer the new style [...]
    RUBY

    expect_correction(<<~RUBY)
      validates :a, :b, numericality: { minimum: 1 }
    RUBY
  end

  it 'registers an offense with a proc' do
    expect_offense(<<~RUBY)
      validates_comparison_of :a, :b, greater_than: -> { Time.zone.today }
      ^^^^^^^^^^^^^^^^^^^^^^^ Prefer the new style [...]
    RUBY

    expect_correction(<<~RUBY)
      validates :a, :b, comparison: { greater_than: -> { Time.zone.today } }
    RUBY
  end

  it 'registers an offense with a splat' do
    expect_offense(<<~RUBY)
      validates_numericality_of :a, *b
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer the new style [...]
    RUBY

    expect_correction(<<~RUBY)
      validates :a, *b, numericality: true
    RUBY
  end

  it 'registers an offense with a splat and options' do
    expect_offense(<<~RUBY)
      validates_numericality_of :a, *b, :c, minimum: 1
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer the new style [...]
    RUBY

    expect_correction(<<~RUBY)
      validates :a, *b, :c, numericality: { minimum: 1 }
    RUBY
  end

  it 'registers no offense with trailing send node' do
    expect_no_offenses(<<~RUBY)
      validates_numericality_of :a, b
    RUBY
  end

  it 'registers no offense with trailing constant' do
    expect_no_offenses(<<~RUBY)
      validates_numericality_of :a, B
    RUBY
  end

  it 'registers no offense with trailing local variable' do
    expect_no_offenses(<<~RUBY)
      b = { minimum: 1 }
      validates_numericality_of :a, b
    RUBY
  end

  it 'registers no offense when no arguments are passed' do
    expect_no_offenses(<<~RUBY)
      validates_numericality_of
    RUBY
  end
end
