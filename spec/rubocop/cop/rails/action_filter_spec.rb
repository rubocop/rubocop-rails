# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActionFilter, :config do
  let(:cop_config) { { 'Include' => nil } }

  describe '::FILTER_METHODS' do
    it 'contains all of the filter methods' do
      expect(described_class::FILTER_METHODS).to eq(%i[
                                                      after_filter
                                                      append_after_filter
                                                      append_around_filter
                                                      append_before_filter
                                                      around_filter
                                                      before_filter
                                                      prepend_after_filter
                                                      prepend_around_filter
                                                      prepend_before_filter
                                                      skip_after_filter
                                                      skip_around_filter
                                                      skip_before_filter
                                                      skip_filter
                                                    ])
    end
  end

  describe '::ACTION_METHODS' do
    it 'contains all of the action methods' do
      expect(described_class::ACTION_METHODS).to eq(%i[
                                                      after_action
                                                      append_after_action
                                                      append_around_action
                                                      append_before_action
                                                      around_action
                                                      before_action
                                                      prepend_after_action
                                                      prepend_around_action
                                                      prepend_before_action
                                                      skip_after_action
                                                      skip_around_action
                                                      skip_before_action
                                                      skip_action_callback
                                                    ])
    end
  end

  context 'when style is action' do
    before do
      cop_config['EnforcedStyle'] = 'action'
    end

    described_class::FILTER_METHODS.each do |method|
      it "registers an offense for #{method}" do
        offenses = inspect_source("#{method} :name")
        expect(offenses.size).to eq(1)
      end

      it "registers an offense for #{method} with block" do
        offenses = inspect_source("#{method} { |controller| something }")
        expect(offenses.size).to eq(1)
      end
    end

    described_class::ACTION_METHODS.each do |method|
      it "accepts #{method}" do
        expect_no_offenses("#{method} :something")
      end
    end

    it 'autocorrects to preferred method' do
      new_source = autocorrect_source_file('before_filter :test')
      expect(new_source).to eq('before_action :test')
    end
  end

  context 'when style is filter' do
    before do
      cop_config['EnforcedStyle'] = 'filter'
    end

    described_class::ACTION_METHODS.each do |method|
      it "registers an offense for #{method}" do
        offenses = inspect_source("#{method} :name")
        expect(offenses.size).to eq(1)
      end

      it "registers an offense for #{method} with block" do
        offenses = inspect_source("#{method} { |controller| something }")
        expect(offenses.size).to eq(1)
      end
    end

    described_class::FILTER_METHODS.each do |method|
      it "accepts #{method}" do
        expect_no_offenses("#{method} :something")
      end
    end

    it 'autocorrects to preferred method' do
      new_source = autocorrect_source_file('before_action :test')
      expect(new_source).to eq('before_filter :test')
    end
  end
end
