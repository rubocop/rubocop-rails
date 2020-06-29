# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Pluck, :config do
  subject(:cop) { described_class.new(config) }

  %w[map collect].each do |method|
    context 'when using Rails 5.0 or newer', :rails50 do
      context "when `#{method}` can be replaced with `pluck`" do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            x.%{method} { |a| a[:foo] }
              ^{method}^^^^^^^^^^^^^^^^ Prefer `pluck(:foo)` over `%{method} { |a| a[:foo] }`.
          RUBY

          expect_correction(<<~RUBY)
            x.pluck(:foo)
          RUBY
        end
      end

      context 'when the block argument is unused' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            x.#{method} { |a| b[:foo] }
          RUBY
        end
      end

      context 'when the value is not a symbol' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            x.#{method} { |a| a['foo'] }
          RUBY
        end
      end
    end

    context 'when using Rails 4.2 or older', :rails42 do
      it 'does not registers an offense' do
        expect_no_offenses(<<~RUBY)
          x.#{method} { |a| a[:foo] }
        RUBY
      end
    end
  end
end
