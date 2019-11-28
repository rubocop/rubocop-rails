# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::NoVariablePrecisionDecimal, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'Include' => nil } }

  context 'with add_column call' do
    context 'with precision missing' do
      it 'reports an offense' do
        expect_offense(<<~RUBY)
          add_column :fees, :amount, :decimal, scale: 4
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Set explicit scale and precision when adding Decimal column.
        RUBY
      end
    end

    context 'with scale missing' do
      it 'reports an offense' do
        expect_offense(<<~RUBY)
          add_column :fees, :amount, :decimal, precision: 6
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Set explicit scale and precision when adding Decimal column.
        RUBY
      end
    end

    context 'with precision and scale explicitly defined' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          add_column :fees, :amount, :decimal, precision: 6, scale: 4
        RUBY
      end
    end
  end
end
