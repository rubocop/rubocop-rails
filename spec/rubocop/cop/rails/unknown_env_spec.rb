# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::UnknownEnv, :config do
  let(:cop_config) do
    {
      'Environments' => %w[
        development
        production
        test
      ]
    }
  end

  # The following is a workaround which handles an upstream Ruby issue in which
  # the DidYouMean constants may not be available in versions of Ruby where
  # they are supposed to be available.
  if defined?(DidYouMean::SpellChecker)
    context 'when DidYouMean is available' do
      it 'registers an offense for typo of environment name' do
        expect_offense(<<~RUBY)
          Rails.env.proudction?
                    ^^^^^^^^^^^ Unknown environment `proudction`. Did you mean `production`?
          Rails.env.developpment?
                    ^^^^^^^^^^^^^ Unknown environment `developpment`. Did you mean `development`?
          Rails.env.something?
                    ^^^^^^^^^^ Unknown environment `something`.
          Rails.env.local?
                    ^^^^^^ Unknown environment `local`.
        RUBY
      end

      it 'registers an offense for typo of environment name with `==` operator' do
        expect_offense(<<~RUBY)
          Rails.env == 'proudction'
                       ^^^^^^^^^^^^ Unknown environment `proudction`. Did you mean `production`?
          'developpment' == Rails.env
          ^^^^^^^^^^^^^^ Unknown environment `developpment`. Did you mean `development`?

          'something' === Rails.env
          ^^^^^^^^^^^ Unknown environment `something`.

          'local' === Rails.env
          ^^^^^^^ Unknown environment `local`.
        RUBY
      end

      it 'registers an offense when case condition is an unknown environment name' do
        expect_offense(<<~RUBY)
          case Rails.env
          when 'proudction'
               ^^^^^^^^^^^^ Unknown environment `proudction`. Did you mean `production`?
            something
          end
        RUBY
      end

      it 'registers an offense for `case` when there are multiple conditions in one `when`' do
        expect_offense(<<~RUBY)
          case Rails.env
          when 'development', 'proudction'
                              ^^^^^^^^^^^^ Unknown environment `proudction`. Did you mean `production`?
            something
          end
        RUBY
      end

      it 'accepts when case condition is not a string' do
        expect_no_offenses(<<~RUBY)
          case Rails.env
          when proudction
            something
          end
        RUBY
      end

      context 'when Rails 7.1 or newer', :rails71 do
        it 'registers an offense when case condition is string "local"' do
          expect_offense(<<~RUBY)
            case Rails.env
            when 'local'
                 ^^^^^^^ Unknown environment `local`.
              something
            end
          RUBY
        end
      end
    end
  else
    context 'when DidYouMean is not available' do
      it 'registers an offense for typo of environment name' do
        expect_offense(<<~RUBY)
          Rails.env.proudction?
                    ^^^^^^^^^^^ Unknown environment `proudction`.
          Rails.env.developpment?
                    ^^^^^^^^^^^^^ Unknown environment `developpment`.
          Rails.env.something?
                    ^^^^^^^^^^ Unknown environment `something`.

          Rails.env.local?
                    ^^^^^^ Unknown environment `local`.
        RUBY
      end

      it 'registers an offense for typo of environment name with `==` operator' do
        expect_offense(<<~RUBY)
          Rails.env == 'proudction'
                       ^^^^^^^^^^^^ Unknown environment `proudction`.
          'developpment' == Rails.env
          ^^^^^^^^^^^^^^ Unknown environment `developpment`.

          'something' === Rails.env
          ^^^^^^^^^^^ Unknown environment `something`.

          'local' === Rails.env
          ^^^^^^^ Unknown environment `local`.
        RUBY
      end
    end
  end

  it 'accepts correct environment name' do
    expect_no_offenses(<<~RUBY)
      Rails.env.production?
      Rails.env == 'production'
    RUBY
  end

  context 'when Rails 7.1 or newer', :rails71 do
    it 'registers an offense for environment `local` with `==` operator' do
      expect_offense(<<~RUBY)
        Rails.env == 'local'
                     ^^^^^^^ Unknown environment `local`.
      RUBY
    end

    it 'accepts local as an environment name' do
      expect_no_offenses(<<~RUBY)
        Rails.env.local?
      RUBY
    end

    it 'does not mutate the cop config' do
      expect_no_offenses(<<~RUBY)
        Rails.env.local?
      RUBY

      expect(cop_config['Environments'].include?('local')).to be(false)
    end

    context 'when `Environments` is nil' do
      let(:cop_config) do
        {
          'Environments' => nil
        }
      end

      it 'accepts local as an environment name' do
        expect_no_offenses(<<~RUBY)
          Rails.env.local?
        RUBY
      end
    end
  end
end
