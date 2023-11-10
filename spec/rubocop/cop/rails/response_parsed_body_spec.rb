# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ResponseParsedBody, :config do
  context 'when `response.parsed_body` is used' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        expect(response.parsed_body).to eq('foo' => 'bar')
      RUBY
    end
  end

  context 'when Rails version is 4.2 or older', :rails42 do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        expect(JSON.parse(response.body)).to eq('foo' => 'bar')
      RUBY
    end
  end

  context 'when `JSON.parse(response.body)` is used' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        expect(JSON.parse(response.body)).to eq('foo' => 'bar')
               ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body` to `JSON.parse(response.body)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(response.parsed_body).to eq('foo' => 'bar')
      RUBY
    end
  end

  context 'when `::JSON.parse(response.body)` is used' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        expect(::JSON.parse(response.body)).to eq('foo' => 'bar')
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body` to `JSON.parse(response.body)`.
      RUBY

      expect_correction(<<~RUBY)
        expect(response.parsed_body).to eq('foo' => 'bar')
      RUBY
    end
  end

  context 'when `Nokogiri::HTML.parse(response.body)` is used on Rails 7.0', :rails70 do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        Nokogiri::HTML.parse(response.body)
      RUBY
    end
  end

  context 'when `Nokogiri::HTML.parse(response.body)` is used on Rails 7.1', :rails71 do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        Nokogiri::HTML.parse(response.body)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body` to `Nokogiri::HTML.parse(response.body)`.
      RUBY

      expect_correction(<<~RUBY)
        response.parsed_body
      RUBY
    end
  end

  context 'when `Nokogiri::HTML5.parse(response.body)` is used on Rails 7.1', :rails71 do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        Nokogiri::HTML5.parse(response.body)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body` to `Nokogiri::HTML5.parse(response.body)`.
      RUBY

      expect_correction(<<~RUBY)
        response.parsed_body
      RUBY
    end
  end
end
