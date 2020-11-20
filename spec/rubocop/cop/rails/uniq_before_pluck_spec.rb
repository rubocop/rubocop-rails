# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::UniqBeforePluck, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples_for 'UniqBeforePluck cop' \
    do |method, source, action, corrected = nil|
      if action == :correct
        it "finds the use of #{method} after pluck in #{source}" do
          offenses = inspect_source(source)
          expect(offenses.first.message).to eq('Use `distinct` before `pluck`.')
          corrected_source = corrected || 'Model.distinct.pluck(:id)'
          expect(autocorrect_source(source)).to eq(corrected_source)
        end
      else
        it "ignores pluck without errors in #{source}" do
          expect_no_offenses(source)
        end
      end
    end

  shared_examples_for 'mode independent behavior' do |method|
    it_behaves_like 'UniqBeforePluck cop', method,
                    "Model.pluck(:id).#{method}", :correct

    it_behaves_like 'UniqBeforePluck cop', method,
                    ['Model.pluck(:id)',
                     "  .#{method}"].join("\n"), :correct

    it_behaves_like 'UniqBeforePluck cop', method,
                    ['Model.pluck(:id).',
                     "  #{method}"].join("\n"), :correct

    context "#{method} before pluck" do
      it_behaves_like 'UniqBeforePluck cop', method,
                      "Model.where(foo: 1).#{method}.pluck(:something)", :ignore
    end

    context "#{method} without a receiver" do
      it_behaves_like 'UniqBeforePluck cop', method,
                      "#{method}.something", :ignore
    end

    context "#{method} without pluck" do
      it_behaves_like 'UniqBeforePluck cop', method,
                      "Model.#{method}", :ignore
    end

    context "#{method} with a block" do
      it_behaves_like 'UniqBeforePluck cop', method,
                      "Model.where(foo: 1).pluck(:id).#{method} { |k| k[0] }",
                      :ignore
    end
  end

  shared_examples_for 'mode dependent offenses' do |method, action|
    it_behaves_like 'UniqBeforePluck cop', method,
                    "Model.scope.pluck(:id).#{method}", action,
                    'Model.scope.distinct.pluck(:id)'

    it_behaves_like 'UniqBeforePluck cop', method,
                    "instance.assoc.pluck(:id).#{method}", action,
                    'instance.assoc.distinct.pluck(:id)'
  end

  it 'registers an offense' do
    expect_offense(<<~RUBY)
      Model.pluck(:id).uniq
                       ^^^^ Use `distinct` before `pluck`.
    RUBY
  end

  %w[uniq distinct].each do |method|
    context 'when the enforced mode is conservative' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'conservative', 'AutoCorrect' => true }
      end

      it_behaves_like 'mode independent behavior', method

      it_behaves_like 'mode dependent offenses', method, :ignore
    end

    context 'when the enforced mode is aggressive' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'aggressive', 'AutoCorrect' => true }
      end

      it_behaves_like 'mode independent behavior', method

      it_behaves_like 'mode dependent offenses', method, :correct
    end
  end
end
