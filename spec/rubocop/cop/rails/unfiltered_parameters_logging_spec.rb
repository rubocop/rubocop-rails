# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::UnfilteredParametersLogging, :config do
  it 'registers an offense when logging raw controller parameters' do
    expect_offense(<<~RUBY)
      Rails.logger.info(params)
                        ^^^^^^ Avoid logging unfiltered parameters. Use `request.filtered_parameters` for configured filtering, or select reviewed fields.
    RUBY
  end

  %w[debug info warn error fatal unknown].each do |level|
    it "registers an offense when using the #{level} logging method" do
      source = "Rails.logger.#{level}(params)"

      expect(inspect_source(source).map { |offense| offense.location.source }).to eq(['params'])
    end
  end

  %w[add log].each do |method|
    it "registers an offense when using #{method} with an explicit severity" do
      source = "Rails.logger.#{method}(Logger::INFO, params)"

      expect(inspect_source(source).map { |offense| offense.location.source }).to eq(['params'])
    end
  end

  operators = %w[. &.]

  [
    'Rails.logger', '::Rails.logger', 'logger', 'self.logger',
    'Rails.logger.tagged("request")', 'logger.tagged("a").tagged("b")',
    'Rails.logger&.tagged("request")'
  ].each do |receiver|
    operators.each do |operator|
      it "registers an offense when using #{receiver}#{operator}info" do
        source = "#{receiver}#{operator}info(params)"

        expect(inspect_source(source).map { |offense| offense.location.source }).to eq(['params'])
      end
    end
  end

  [
    'params', 'self.params', 'request.params', 'request.parameters',
    'self.request&.parameters', 'request&.params'
  ].each do |parameters|
    it "registers an offense when logging #{parameters}" do
      source = "Rails.logger.info(#{parameters})"

      expect(inspect_source(source).map { |offense| offense.location.source }).to eq([parameters])
    end
  end

  [
    'params.inspect', 'params.to_s', 'params.to_json', 'params.to_yaml',
    'params.to_h', 'params.to_unsafe_h', 'params.permit!', 'params.except(:password)',
    'params.require(:user)', 'params.require(:user).require(:profile)',
    'params.require(:user).to_json', 'params&.to_json', 'params&.require(:user)',
    'params.to_json.slice(0, 100)'
  ].each do |expression|
    it "registers an offense when logging #{expression}" do
      source = "Rails.logger.info(#{expression})"

      expect(inspect_source(source).map { |offense| offense.location.source }).to eq(['params'])
    end
  end

  it 'registers an offense when interpolating parameters' do
    expect_offense(<<~'RUBY')
      Rails.logger.info("Request: #{params}")
                                    ^^^^^^ Avoid logging unfiltered parameters. Use `request.filtered_parameters` for configured filtering, or select reviewed fields.
    RUBY
  end

  it 'registers an offense when raw parameters are a field selection fallback' do
    expect_offense(<<~RUBY)
      logger.info(params.fetch(:user, params))
                                      ^^^^^^ Avoid logging unfiltered parameters. Use `request.filtered_parameters` for configured filtering, or select reviewed fields.
    RUBY
  end

  it 'does not register an offense when a block transformation is summarized' do
    expect_no_offenses(<<~RUBY)
      logger.info(params.to_unsafe_h.select { |key, _value| key.start_with?('public_') }.count)
      logger.info(params.map { |key, _value| key }.size)
      logger.info(params.select { |key, _value| key == 'id' }.empty?)
    RUBY
  end

  it 'registers an offense when nesting parameters in a structured message' do
    expect_offense(<<~RUBY)
      logger.info(context: { parameters: params })
                                         ^^^^^^ Avoid logging unfiltered parameters. Use `request.filtered_parameters` for configured filtering, or select reviewed fields.
    RUBY
  end

  it 'registers an offense in a tagged logger message block' do
    expect_offense(<<~RUBY)
      Rails.logger.tagged('request').info { params }
                                            ^^^^^^ Avoid logging unfiltered parameters. Use `request.filtered_parameters` for configured filtering, or select reviewed fields.
    RUBY
  end

  it 'registers offenses in both the arguments and the message block' do
    expect_offense(<<~RUBY)
      logger.info(params) { request.parameters }
                  ^^^^^^ Avoid logging unfiltered parameters. Use `request.filtered_parameters` for configured filtering, or select reviewed fields.
                            ^^^^^^^^^^^^^^^^^^ Avoid logging unfiltered parameters. Use `request.filtered_parameters` for configured filtering, or select reviewed fields.
    RUBY
  end

  [
    'request.filtered_parameters', 'request.filtered_parameters.to_json',
    'params.slice(:id)', 'params.permit(:id)', 'params.expect(:id)',
    'params.expect!(user: [:id])', 'params[:id]', 'params.fetch(:id)', 'params.dig(:user, :id)',
    'params.require(:user).permit(:id)', 'params.require(:user).require(:profile).slice(:id)',
    'params&.require(:user)&.permit(:id)&.to_json', 'request.params.slice(:id).to_json',
    'params.size', 'params.length', 'params.count', 'params.keys', 'params.empty?', 'params.key?(:password)',
    'params.to_json.bytesize', 'params.to_unsafe_h.keys'
  ].each do |expression|
    it "does not register an offense when logging #{expression}" do
      expect_no_offenses("Rails.logger.info(#{expression})")
    end
  end

  it 'does not register an offense for a filtered message block' do
    expect_no_offenses(<<~RUBY)
      Rails.logger.info { request.filtered_parameters }
    RUBY
  end

  it 'does not register an offense for a logger call without a message' do
    expect_no_offenses(<<~RUBY)
      Rails.logger.info
      Rails.logger.info {}
    RUBY
  end

  %w[tracker @logger Sidekiq.logger Other::Rails.logger].each do |receiver|
    it "does not register an offense for #{receiver}" do
      expect_no_offenses("#{receiver}.info(params)")
    end
  end

  it 'does not register an offense outside a logging call' do
    expect_no_offenses(<<~RUBY)
      process(params)
      info(params)
      Rails.logger.tagged(params)
    RUBY
  end

  it 'does not mistake a logging method argument for a parameter receiver' do
    expect_no_offenses(<<~RUBY)
      Rails.logger.info(request.filtered_parameters, params: false)
    RUBY
  end
end
