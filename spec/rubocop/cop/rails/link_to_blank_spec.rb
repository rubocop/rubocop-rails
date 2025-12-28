# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::LinkToBlank, :config do
  context 'when using link_to' do
    context 'when not using target _blank' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          link_to 'Click here', 'https://www.example.com'
        RUBY
      end

      it 'does not register an offense when passing options' do
        expect_no_offenses(<<~RUBY)
          link_to 'Click here', 'https://www.example.com', class: 'big'
        RUBY
      end

      it 'does not register an offense when using the block syntax' do
        expect_no_offenses(<<~RUBY)
          link_to 'https://www.example.com', class: 'big' do
            "Click Here"
          end
        RUBY
      end
    end

    context 'when using target_blank' do
      context 'when using no rel' do
        it 'registers and corrects an offense' do
          expect_offense(<<~RUBY)
            link_to 'Click here', 'https://www.example.com', target: '_blank'
                                                             ^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY

          expect_correction(<<~RUBY)
            link_to 'Click here', 'https://www.example.com', target: '_blank', rel: 'noopener'
          RUBY
        end

        it 'registers an offense when using a string for the target key' do
          expect_offense(<<~RUBY)
            link_to 'Click here', 'https://www.example.com', "target" => '_blank'
                                                             ^^^^^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY
        end

        it 'registers an offense when using a symbol for the target value' do
          expect_offense(<<~RUBY)
            link_to 'Click here', 'https://www.example.com', target: :_blank
                                                             ^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY
        end

        it 'registers an offense and autocorrects when using the block syntax' do
          expect_offense(<<~RUBY)
            link_to 'https://www.example.com', target: '_blank' do
                                               ^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
              "Click here"
            end
          RUBY

          expect_correction(<<~RUBY)
            link_to 'https://www.example.com', target: '_blank', rel: 'noopener' do
              "Click here"
            end
          RUBY
        end

        it 'autocorrects with a new rel when using the block syntax with parenthesis' do
          new_source = autocorrect_source(<<~RUBY)
            link_to('https://www.example.com', target: '_blank') do
              "Click here"
            end
          RUBY

          expect(new_source).to eq(<<~RUBY)
            link_to('https://www.example.com', target: '_blank', rel: 'noopener') do
              "Click here"
            end
          RUBY
        end

        it 'autocorrects with a new rel when using a symbol for the target value' do
          new_source = autocorrect_source(<<~RUBY)
            link_to 'Click here', 'https://www.example.com', target: :_blank
          RUBY

          expect(new_source).to eq(<<~RUBY)
            link_to 'Click here', 'https://www.example.com', target: :_blank, rel: :noopener
          RUBY
        end

        it 'registers and corrects an offense when using hash brackets for the option' do
          expect_offense(<<~RUBY)
            link_to 'Click here', 'https://www.example.com', { target: :_blank }
                                                               ^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY

          expect_correction(<<~RUBY)
            link_to 'Click here', 'https://www.example.com', { target: :_blank, rel: :noopener }
          RUBY
        end
      end

      context 'when using rel' do
        context 'when the rel does not contain noopener' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY)
              link_to 'Click here', 'https://www.example.com', "target" => '_blank', rel: 'unrelated'
                                                               ^^^^^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
            RUBY

            expect_correction(<<~RUBY)
              link_to 'Click here', 'https://www.example.com', "target" => '_blank', rel: 'unrelated noopener'
            RUBY
          end
        end

        context 'when the rel contains noopener' do
          it 'registers no offense' do
            expect_no_offenses(<<~RUBY)
              link_to 'Click here', 'https://www.example.com', target: '_blank', rel: 'noopener unrelated'
            RUBY
          end
        end

        context 'when the rel contains noreferrer' do
          it 'registers no offense' do
            expect_no_offenses(<<~RUBY)
              link_to 'Click here', 'https://www.example.com', target: '_blank', rel: 'unrelated noreferrer'
            RUBY
          end
        end

        context 'when the rel contains noopener and noreferrer' do
          it 'registers no offense' do
            expect_no_offenses(<<~RUBY)
              link_to 'Click here', 'https://www.example.com', target: '_blank', rel: 'noopener noreferrer'
            RUBY
          end
        end

        context 'when the rel is symbol noopener' do
          it 'registers no offense' do
            expect_no_offenses(<<~RUBY)
              link_to 'Click here', 'https://www.example.com', target: :_blank, rel: :noopener
            RUBY
          end
        end
      end
    end
  end

  context 'when using link_to_if' do
    context 'when not using target _blank' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          link_to_if condition?, 'Click here', 'https://www.example.com'
        RUBY
      end

      it 'does not register an offense when passing options' do
        expect_no_offenses(<<~RUBY)
          link_to_if condition?, 'Click here', 'https://www.example.com', class: 'big'
        RUBY
      end

      it 'does not register an offense when using the block syntax' do
        expect_no_offenses(<<~RUBY)
          link_to_if condition?, 'https://www.example.com', class: 'big' do
            "Click Here"
          end
        RUBY
      end
    end

    context 'when using target_blank' do
      context 'when using no rel' do
        it 'registers and corrects an offense' do
          expect_offense(<<~RUBY)
            link_to_if condition?, 'Click here', 'https://www.example.com', target: '_blank'
                                                                            ^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY

          expect_correction(<<~RUBY)
            link_to_if condition?, 'Click here', 'https://www.example.com', target: '_blank', rel: 'noopener'
          RUBY
        end

        it 'registers an offense when using a string for the target key' do
          expect_offense(<<~RUBY)
            link_to_if condition?, 'Click here', 'https://www.example.com', "target" => '_blank'
                                                                            ^^^^^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY
        end

        it 'registers an offense when using a symbol for the target value' do
          expect_offense(<<~RUBY)
            link_to_if condition?, 'Click here', 'https://www.example.com', target: :_blank
                                                                            ^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY
        end

        it 'registers an offense and autocorrects when using the block syntax' do
          expect_offense(<<~RUBY)
            link_to_if condition?, 'https://www.example.com', target: '_blank' do
                                                              ^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
              "Click here"
            end
          RUBY

          expect_correction(<<~RUBY)
            link_to_if condition?, 'https://www.example.com', target: '_blank', rel: 'noopener' do
              "Click here"
            end
          RUBY
        end

        it 'autocorrects with a new rel when using the block syntax with parenthesis' do
          new_source = autocorrect_source(<<~RUBY)
            link_to_if(condition?, 'https://www.example.com', target: '_blank') do
              "Click here"
            end
          RUBY

          expect(new_source).to eq(<<~RUBY)
            link_to_if(condition?, 'https://www.example.com', target: '_blank', rel: 'noopener') do
              "Click here"
            end
          RUBY
        end

        it 'autocorrects with a new rel when using a symbol for the target value' do
          new_source = autocorrect_source(<<~RUBY)
            link_to_if condition?, 'Click here', 'https://www.example.com', target: :_blank
          RUBY

          expect(new_source).to eq(<<~RUBY)
            link_to_if condition?, 'Click here', 'https://www.example.com', target: :_blank, rel: :noopener
          RUBY
        end

        it 'registers and corrects an offense when using hash brackets for the option' do
          expect_offense(<<~RUBY)
            link_to_if condition?, 'Click here', 'https://www.example.com', { target: :_blank }
                                                                              ^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY

          expect_correction(<<~RUBY)
            link_to_if condition?, 'Click here', 'https://www.example.com', { target: :_blank, rel: :noopener }
          RUBY
        end
      end

      context 'when using rel' do
        context 'when the rel does not contain noopener' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY)
              link_to_if condition?, 'Click here', 'https://www.example.com', "target" => '_blank', rel: 'unrelated'
                                                                              ^^^^^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
            RUBY

            expect_correction(<<~RUBY)
              link_to_if condition?, 'Click here', 'https://www.example.com', "target" => '_blank', rel: 'unrelated noopener'
            RUBY
          end
        end

        context 'when the rel contains noopener' do
          it 'registers no offense' do
            expect_no_offenses(<<~RUBY)
              link_to_if condition?, 'Click here', 'https://www.example.com', target: '_blank', rel: 'noopener unrelated'
            RUBY
          end
        end

        context 'when the rel contains noreferrer' do
          it 'registers no offense' do
            expect_no_offenses(<<~RUBY)
              link_to_if condition?, 'Click here', 'https://www.example.com', target: '_blank', rel: 'unrelated noreferrer'
            RUBY
          end
        end

        context 'when the rel contains noopener and noreferrer' do
          it 'registers no offense' do
            expect_no_offenses(<<~RUBY)
              link_to_if condition?, 'Click here', 'https://www.example.com', target: '_blank', rel: 'noopener noreferrer'
            RUBY
          end
        end

        context 'when the rel is symbol noopener' do
          it 'registers no offense' do
            expect_no_offenses(<<~RUBY)
              link_to_if condition?, 'Click here', 'https://www.example.com', target: :_blank, rel: :noopener
            RUBY
          end
        end
      end
    end
  end

  context 'when using link_to_unless' do
    context 'when not using target _blank' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          link_to_unless condition?, 'Click here', 'https://www.example.com'
        RUBY
      end

      it 'does not register an offense when passing options' do
        expect_no_offenses(<<~RUBY)
          link_to_unless condition?, 'Click here', 'https://www.example.com', class: 'big'
        RUBY
      end

      it 'does not register an offense when using the block syntax' do
        expect_no_offenses(<<~RUBY)
          link_to_unless condition?, 'https://www.example.com', class: 'big' do
            "Click Here"
          end
        RUBY
      end
    end

    context 'when using target_blank' do
      context 'when using no rel' do
        it 'registers and corrects an offense' do
          expect_offense(<<~RUBY)
            link_to_unless condition?, 'Click here', 'https://www.example.com', target: '_blank'
                                                                                ^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY

          expect_correction(<<~RUBY)
            link_to_unless condition?, 'Click here', 'https://www.example.com', target: '_blank', rel: 'noopener'
          RUBY
        end

        it 'registers an offense when using a string for the target key' do
          expect_offense(<<~RUBY)
            link_to_unless condition?, 'Click here', 'https://www.example.com', "target" => '_blank'
                                                                                ^^^^^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY
        end

        it 'registers an offense when using a symbol for the target value' do
          expect_offense(<<~RUBY)
            link_to_unless condition?, 'Click here', 'https://www.example.com', target: :_blank
                                                                                ^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY
        end

        it 'registers an offense and autocorrects when using the block syntax' do
          expect_offense(<<~RUBY)
            link_to_unless condition?, 'https://www.example.com', target: '_blank' do
                                                                  ^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
              "Click here"
            end
          RUBY

          expect_correction(<<~RUBY)
            link_to_unless condition?, 'https://www.example.com', target: '_blank', rel: 'noopener' do
              "Click here"
            end
          RUBY
        end

        it 'autocorrects with a new rel when using the block syntax with parenthesis' do
          new_source = autocorrect_source(<<~RUBY)
            link_to_unless(condition?, 'https://www.example.com', target: '_blank') do
              "Click here"
            end
          RUBY

          expect(new_source).to eq(<<~RUBY)
            link_to_unless(condition?, 'https://www.example.com', target: '_blank', rel: 'noopener') do
              "Click here"
            end
          RUBY
        end

        it 'autocorrects with a new rel when using a symbol for the target value' do
          new_source = autocorrect_source(<<~RUBY)
            link_to_unless condition?, 'Click here', 'https://www.example.com', target: :_blank
          RUBY

          expect(new_source).to eq(<<~RUBY)
            link_to_unless condition?, 'Click here', 'https://www.example.com', target: :_blank, rel: :noopener
          RUBY
        end

        it 'registers and corrects an offense when using hash brackets for the option' do
          expect_offense(<<~RUBY)
            link_to_unless condition?, 'Click here', 'https://www.example.com', { target: :_blank }
                                                                                  ^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY

          expect_correction(<<~RUBY)
            link_to_unless condition?, 'Click here', 'https://www.example.com', { target: :_blank, rel: :noopener }
          RUBY
        end
      end

      context 'when using rel' do
        context 'when the rel does not contain noopener' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY)
              link_to_unless condition?, 'Click here', 'https://www.example.com', "target" => '_blank', rel: 'unrelated'
                                                                                  ^^^^^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
            RUBY

            expect_correction(<<~RUBY)
              link_to_unless condition?, 'Click here', 'https://www.example.com', "target" => '_blank', rel: 'unrelated noopener'
            RUBY
          end
        end

        context 'when the rel contains noopener' do
          it 'registers no offense' do
            expect_no_offenses(<<~RUBY)
              link_to_unless condition?, 'Click here', 'https://www.example.com', target: '_blank', rel: 'noopener unrelated'
            RUBY
          end
        end

        context 'when the rel contains noreferrer' do
          it 'registers no offense' do
            expect_no_offenses(<<~RUBY)
              link_to_unless condition?, 'Click here', 'https://www.example.com', target: '_blank', rel: 'unrelated noreferrer'
            RUBY
          end
        end

        context 'when the rel contains noopener and noreferrer' do
          it 'registers no offense' do
            expect_no_offenses(<<~RUBY)
              link_to_unless condition?, 'Click here', 'https://www.example.com', target: '_blank', rel: 'noopener noreferrer'
            RUBY
          end
        end

        context 'when the rel is symbol noopener' do
          it 'registers no offense' do
            expect_no_offenses(<<~RUBY)
              link_to_unless condition?, 'Click here', 'https://www.example.com', target: :_blank, rel: :noopener
            RUBY
          end
        end
      end
    end
  end
end
