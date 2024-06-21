# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Validation, :config do
  it 'accepts new style validations' do
    expect_no_offenses('validates :name')
  end

  described_class::RESTRICT_ON_SEND.each_with_index do |validation, number|
    it "registers an offense for #{validation}" do
      offenses = inspect_source("#{validation} :name")
      expect(offenses.first.message.include?(described_class::ALLOWLIST[number])).to be(true)
    end
  end

  describe '#autocorrect' do
    shared_examples 'autocorrects' do
      it 'autocorrects' do
        expect(autocorrect_source(source)).to eq(autocorrected_source)
      end
    end

    shared_examples 'does not autocorrect' do
      it 'does not autocorrect' do
        expect(autocorrect_source(source)).to eq(source)
      end
    end

    described_class::TYPES.each do |type|
      context "with validates_#{type}_of" do
        let(:autocorrected_source) do
          type = 'length' if type == 'size'

          "validates :full_name, :birth_date, #{type}: true"
        end

        let(:source) do
          "validates_#{type}_of :full_name, :birth_date"
        end

        include_examples 'autocorrects'
      end

      context "with validates_#{type}_of when method arguments are enclosed in parentheses" do
        let(:autocorrected_source) do
          type = 'length' if type == 'size'

          "validates(:full_name, :birth_date, #{type}: true)"
        end

        let(:source) do
          "validates_#{type}_of(:full_name, :birth_date)"
        end

        include_examples 'autocorrects'
      end

      context "with validates_#{type}_of when attributes are specified with array literal" do
        let(:autocorrected_source) do
          type = 'length' if type == 'size'

          "validates :full_name, :birth_date, #{type}: true"
        end

        let(:source) do
          "validates_#{type}_of [:full_name, :birth_date]"
        end

        include_examples 'autocorrects'
      end

      context "with validates_#{type}_of when attributes are specified with frozen array literal" do
        let(:autocorrected_source) do
          type = 'length' if type == 'size'

          "validates :full_name, :birth_date, #{type}: true"
        end

        let(:source) do
          "validates_#{type}_of [:full_name, :birth_date].freeze"
        end

        include_examples 'autocorrects'
      end

      context "with validates_#{type}_of when attributes are specified with symbol array literal" do
        let(:autocorrected_source) do
          type = 'length' if type == 'size'

          "validates :full_name, :birth_date, #{type}: true"
        end

        let(:source) do
          "validates_#{type}_of %i[full_name birth_date]"
        end

        include_examples 'autocorrects'
      end

      context "with validates_#{type}_of when attributes are specified with frozen symbol array literal" do
        let(:autocorrected_source) do
          type = 'length' if type == 'size'

          "validates :full_name, :birth_date, #{type}: true"
        end

        let(:source) do
          "validates_#{type}_of %i[full_name birth_date].freeze"
        end

        include_examples 'autocorrects'
      end
    end

    context 'with single attribute name' do
      let(:autocorrected_source) do
        'validates :a, numericality: true'
      end

      let(:source) do
        'validates_numericality_of :a'
      end

      include_examples 'autocorrects'
    end

    context 'with multi attribute names' do
      let(:autocorrected_source) do
        'validates :a, :b, numericality: true'
      end

      let(:source) do
        'validates_numericality_of :a, :b'
      end

      include_examples 'autocorrects'
    end

    context 'with non-braced hash literal' do
      let(:autocorrected_source) do
        'validates :a, :b, numericality: { minimum: 1 }'
      end

      let(:source) do
        'validates_numericality_of :a, :b, minimum: 1'
      end

      include_examples 'autocorrects'
    end

    context 'with braced hash literal' do
      let(:autocorrected_source) do
        'validates :a, :b, numericality: { minimum: 1 }'
      end

      let(:source) do
        'validates_numericality_of :a, :b, { minimum: 1 }'
      end

      include_examples 'autocorrects'
    end

    context 'with a proc' do
      let(:autocorrected_source) do
        'validates :a, :b, comparison: { greater_than: -> { Time.zone.today } }'
      end

      let(:source) do
        'validates_comparison_of :a, :b, greater_than: -> { Time.zone.today }'
      end

      include_examples 'autocorrects'
    end

    context 'with splat' do
      let(:autocorrected_source) do
        'validates :a, *b, numericality: true'
      end

      let(:source) do
        'validates_numericality_of :a, *b'
      end

      include_examples 'autocorrects'
    end

    context 'with splat and options' do
      let(:autocorrected_source) do
        'validates :a, *b, :c, numericality: { minimum: 1 }'
      end

      let(:source) do
        'validates_numericality_of :a, *b, :c, minimum: 1'
      end

      include_examples 'autocorrects'
    end

    context 'with trailing send node' do
      let(:source) do
        'validates_numericality_of :a, b'
      end

      include_examples 'does not autocorrect'
    end

    context 'with trailing constant' do
      let(:source) do
        'validates_numericality_of :a, B'
      end

      include_examples 'does not autocorrect'
    end

    context 'with trailing local variable' do
      let(:source) do
        <<~RUBY
          b = { minimum: 1 }
          validates_numericality_of :a, b
        RUBY
      end

      include_examples 'does not autocorrect'
    end
  end
end
