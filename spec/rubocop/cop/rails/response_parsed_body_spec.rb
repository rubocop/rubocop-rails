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
               ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body`.
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
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body`.
      RUBY

      expect_correction(<<~RUBY)
        expect(response.parsed_body).to eq('foo' => 'bar')
      RUBY
    end
  end

  context 'when `Nokogiri::HTML(response.body)` is used on Rails 7.0', :rails70 do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        Nokogiri::HTML(response.body)
      RUBY
    end
  end

  context 'when `Nokogiri::HTML(response.body)`', :rails71 do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        Nokogiri::HTML(response.body)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body`.
      RUBY

      expect_correction(<<~RUBY)
        response.parsed_body
      RUBY
    end
  end

  context 'when `Nokogiri::HTML4(response.body)`', :rails71 do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        Nokogiri::HTML4(response.body)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body`.
      RUBY

      expect_correction(<<~RUBY)
        response.parsed_body
      RUBY
    end
  end

  context 'when `Nokogiri::HTML5(response.body)`', :rails71 do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        Nokogiri::HTML5(response.body)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body`.
      RUBY

      expect_correction(<<~RUBY)
        response.parsed_body
      RUBY
    end
  end

  context 'when `Nokogiri::HTML.parse(response.body)`', :rails71 do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        Nokogiri::HTML.parse(response.body)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body`.
      RUBY

      expect_correction(<<~RUBY)
        response.parsed_body
      RUBY
    end
  end

  context 'when `Nokogiri::HTML4.parse(response.body)`', :rails71 do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        Nokogiri::HTML4.parse(response.body)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body`.
      RUBY

      expect_correction(<<~RUBY)
        response.parsed_body
      RUBY
    end
  end

  context 'when `Nokogiri::HTML5.parse(response.body)`', :rails71 do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        Nokogiri::HTML5.parse(response.body)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body`.
      RUBY

      expect_correction(<<~RUBY)
        response.parsed_body
      RUBY
    end
  end

  context 'when `Nokogiri::HTML::Document.parse(response.body)`', :rails71 do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        Nokogiri::HTML::Document.parse(response.body)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body`.
      RUBY

      expect_correction(<<~RUBY)
        response.parsed_body
      RUBY
    end
  end

  context 'when `Nokogiri::HTML4::Document.parse(response.body)`', :rails71 do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        Nokogiri::HTML4::Document.parse(response.body)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body`.
      RUBY

      expect_correction(<<~RUBY)
        response.parsed_body
      RUBY
    end
  end

  context 'when `Nokogiri::HTML5::Document.parse(response.body)`', :rails71 do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        Nokogiri::HTML5::Document.parse(response.body)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `response.parsed_body`.
      RUBY

      expect_correction(<<~RUBY)
        response.parsed_body
      RUBY
    end
  end
end
