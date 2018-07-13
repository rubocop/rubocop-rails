# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::SkipsModelValidations, :config do
  cop_config = {
    'Blacklist' => %w[decrement!
                      decrement_counter
                      increment!
                      increment_counter
                      toggle!
                      touch
                      update_all
                      update_attribute
                      update_column
                      update_columns
                      update_counters]
  }

  subject(:cop) { described_class.new(config) }

  let(:msg) { 'Avoid using `%s` because it skips validations.' }
  let(:cop_config) { cop_config }

  methods_with_arguments = described_class::METHODS_WITH_ARGUMENTS

  context 'with default blacklist' do
    cop_config['Blacklist'].each do |method_name|
      it "registers an offense for `#{method_name}`" do
        inspect_source("User.#{method_name}(:attr)")
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages)
          .to eq([format(msg, method_name)])
      end
    end

    it 'accepts FileUtils.touch' do
      expect_no_offenses("FileUtils.touch('file')")
    end
  end

  context 'with methods that require at least an argument' do
    methods_with_arguments.each do |method_name|
      it "doesn't register an offense for `#{method_name}`" do
        expect_no_offenses("User.#{method_name}")
      end
    end
  end

  context "with methods that don't require an argument" do
    (cop_config['Blacklist'] - methods_with_arguments).each do |method_name|
      it "registers an offense for `#{method_name}`" do
        inspect_source("User.#{method_name}")
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages)
          .to eq([format(msg, method_name)])
      end
    end
  end

  context 'with `update_attribute` method in blacklist' do
    let(:cop_config) do
      { 'Blacklist' => %w[update_attribute] }
    end

    whitelist = cop_config['Blacklist'].reject do |val|
      val == 'update_attribute'
    end

    whitelist.each do |method_name|
      it "accepts `#{method_name}`" do
        expect_no_offenses("User.#{method_name}")
      end
    end

    it 'registers an offense for `update_attribute`' do
      expect_offense(<<-RUBY.strip_indent)
        user.update_attribute(:website, 'example.com')
             ^^^^^^^^^^^^^^^^ Avoid using `update_attribute` because it skips validations.
      RUBY
    end
  end
end
