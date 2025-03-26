# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Pluck, :config do
  %w[map collect].each do |method|
    context 'when using Rails 5.0 or newer', :rails50 do
      context "when `#{method}` with symbol literal key can be replaced with `pluck`" do
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

      context "when safe navigation `#{method}` with symbol literal key can be replaced with `pluck`" do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            x&.%{method} { |a| a[:foo] }
               ^{method}^^^^^^^^^^^^^^^^ Prefer `pluck(:foo)` over `%{method} { |a| a[:foo] }`.
          RUBY

          expect_correction(<<~RUBY)
            x&.pluck(:foo)
          RUBY
        end
      end

      context "when `#{method}` with string literal key can be replaced with `pluck`" do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            x.%{method} { |a| a['foo'] }
              ^{method}^^^^^^^^^^^^^^^^^ Prefer `pluck('foo')` over `%{method} { |a| a['foo'] }`.
          RUBY

          expect_correction(<<~RUBY)
            x.pluck('foo')
          RUBY
        end
      end

      context "when `#{method}` with method call key can be replaced with `pluck`" do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            x.%{method} { |a| a[obj.do_something] }
              ^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `pluck(obj.do_something)` over `%{method} { |a| a[obj.do_something] }`.
          RUBY

          expect_correction(<<~RUBY)
            x.pluck(obj.do_something)
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

      context 'when the block argument is used in `[]`' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            x.#{method} { |a| a[foo...a.to_something] }
          RUBY
        end
      end

      context 'when receiver is not block argument for `[]`' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            lvar = do_something
            x.#{method} { |id| lvar[id] }
          RUBY
        end
      end

      context 'when there are multiple block arguments' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            x.#{method} { |_, obj| obj['id'] }
          RUBY
        end
      end

      context "when `#{method}` with regexp literal key cannot be replaced with `pluck`" do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            x.#{method} { |a| a[/regexp/] }
          RUBY
        end
      end

      context 'when using Ruby 2.7 or newer', :ruby27 do
        context 'when using numbered parameter' do
          context "when `#{method}` can be replaced with `pluck`" do
            it 'registers an offense' do
              expect_offense(<<~RUBY, method: method)
                x.%{method} { _1[:foo] }
                  ^{method}^^^^^^^^^^^^^ Prefer `pluck(:foo)` over `%{method} { _1[:foo] }`.
              RUBY

              expect_correction(<<~RUBY)
                x.pluck(:foo)
              RUBY
            end
          end

          context 'when the numblock argument is used in `[]`' do
            it 'does not register an offense' do
              expect_no_offenses(<<~RUBY)
                x.#{method} { _1[foo..._1.to_something] }
              RUBY
            end
          end

          context 'when numblock argument is not `_1`' do
            it 'does not register an offense' do
              expect_no_offenses(<<~RUBY)
                x.#{method} { _2['id'] }
              RUBY
            end
          end
        end
      end

      context 'when using Ruby 3.4 or newer', :ruby34, unsupported_on: :parser do
        context 'when using `it` block parameter' do
          context "when `#{method}` can be replaced with `pluck`" do
            it 'registers an offense' do
              expect_offense(<<~RUBY, method: method)
                x.%{method} { it[:foo] }
                  ^{method}^^^^^^^^^^^^^ Prefer `pluck(:foo)` over `%{method} { it[:foo] }`.
              RUBY

              expect_correction(<<~RUBY)
                x.pluck(:foo)
              RUBY
            end
          end

          context 'when the `it` argument is used in `[]`' do
            it 'does not register an offense' do
              expect_no_offenses(<<~RUBY)
                x.#{method} { it[foo...it.to_something] }
              RUBY
            end
          end
        end
      end

      context "when `#{method}` is used in block" do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            n.each do |x|
              x.#{method} { |a| a[:foo] }
            end
          RUBY
        end
      end

      context "when `#{method}` is used in block with other operations" do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            n.each do |x|
              do_something
              x.#{method} { |a| a[:foo] }
            end
          RUBY
        end
      end

      context "when `#{method}` is used in numblock" do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            n.each do
              _1.#{method} { |a| a[:foo] }
            end
          RUBY
        end
      end

      context "when `#{method}` is used in numblock with other operations" do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            n.each do
              do_something
              _1.#{method} { |a| a[:foo] }
            end
          RUBY
        end
      end
    end

    context 'when using Rails 4.2 or older', :rails42 do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          x.#{method} { |a| a[:foo] }
        RUBY
      end
    end
  end
end
