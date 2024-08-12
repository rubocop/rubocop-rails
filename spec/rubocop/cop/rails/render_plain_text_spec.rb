# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RenderPlainText, :config do
  shared_examples 'checks_common_offense' do
    it 'registers an offense and corrects when using `render text:` with `content_type: "text/plain"`' do
      expect_offense(<<~RUBY)
        render text: 'Ruby!', content_type: 'text/plain'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `render plain:` over `render text:`.
      RUBY

      expect_correction(<<~RUBY)
        render plain: 'Ruby!'
      RUBY
    end

    it 'does not register an offense when using `render text:` with `content_type: "text/html"`' do
      expect_no_offenses(<<~RUBY)
        render text: 'Ruby!', content_type: 'text/html'
      RUBY
    end

    it 'does not register an offense when `content_type` is a constant' do
      expect_no_offenses(<<~RUBY)
        render text: 'Ruby!', content_type: Foo
      RUBY
    end

    it 'does not register an offense when using `render plain:`' do
      expect_no_offenses(<<~RUBY)
        render plain: 'Ruby!'
      RUBY
    end
  end

  context 'when ContentTypeCompatibility set to true' do
    let(:cop_config) do
      { 'ContentTypeCompatibility' => true }
    end

    it 'does not register an offense when using `render text:`' do
      expect_no_offenses(<<~RUBY)
        render text: 'Ruby!'
      RUBY
    end

    it_behaves_like('checks_common_offense')
  end

  context 'when ContentTypeCompatibility set to false' do
    let(:cop_config) do
      { 'ContentTypeCompatibility' => false }
    end

    it 'registers an offense and corrects when using `render text:`' do
      expect_offense(<<~RUBY)
        render text: 'Ruby!'
        ^^^^^^^^^^^^^^^^^^^^ Prefer `render plain:` over `render text:`.
      RUBY

      expect_correction(<<~RUBY)
        render plain: 'Ruby!'
      RUBY
    end

    it_behaves_like('checks_common_offense')
  end
end
