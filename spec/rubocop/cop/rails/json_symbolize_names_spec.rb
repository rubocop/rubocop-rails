# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::JSONSymbolizeNames, :config do
  %i[load_file load_file! parse parse!].each do |method_name|
    context "with `#{method_name}` method" do
      it "registers an offense for `JSON.#{method_name}` followed by `deep_symbolize_keys`" do
        expect_offense(<<~RUBY, method_name: method_name)
          JSON.#{method_name}(json).deep_symbolize_keys
          ^^^^^^{method_name}^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `symbolize_names` option.
        RUBY

        expect_correction(<<~RUBY)
          JSON.#{method_name}(json, symbolize_names: true)
        RUBY
      end

      it "registers an offense for `JSON.#{method_name}` followed by `deep_symbolize_keys` with string literal" do
        expect_offense(<<~RUBY, method_name: method_name)
          JSON.#{method_name}('{"foo": "bar"}').deep_symbolize_keys
          ^^^^^^{method_name}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `symbolize_names` option.
        RUBY

        expect_correction(<<~RUBY)
          JSON.#{method_name}('{"foo": "bar"}', symbolize_names: true)
        RUBY
      end

      it "registers an offense for `::JSON.#{method_name}` followed by `deep_symbolize_keys`" do
        expect_offense(<<~RUBY, method_name: method_name)
          ::JSON.#{method_name}(json).deep_symbolize_keys
          ^^^^^^^^{method_name}^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `symbolize_names` option.
        RUBY

        expect_correction(<<~RUBY)
          ::JSON.#{method_name}(json, symbolize_names: true)
        RUBY
      end

      it "registers an offense for `::JSON.#{method_name}` followed by `deep_symbolize_keys` with safe navigation" do
        expect_offense(<<~RUBY, method_name: method_name)
          ::JSON.#{method_name}(json_null)&.deep_symbolize_keys
          ^^^^^^^^{method_name}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `symbolize_names` option.
        RUBY

        expect_correction(<<~RUBY)
          ::JSON.#{method_name}(json_null, symbolize_names: true)
        RUBY
      end

      it "registers an offense for `JSON.#{method_name}` followed by `deep_symbolize_keys` with non-literal option" do
        expect_offense(<<~RUBY, method_name: method_name)
          ::JSON.#{method_name}(json, options)&.deep_symbolize_keys
          ^^^^^^^^{method_name}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `symbolize_names` option.
        RUBY

        expect_correction(<<~RUBY)
          ::JSON.#{method_name}(json, options, symbolize_names: true)
        RUBY
      end

      it "does not register an offense for `JSON.#{method_name}` with `symbolize_names` option" do
        expect_no_offenses(<<~RUBY)
          JSON.#{method_name}(json, symbolize_names: true)
        RUBY
      end

      it "does not register an offense for single `JSON.#{method_name}`" do
        expect_no_offenses(<<~RUBY)
          JSON.#{method_name}(json)
        RUBY
      end

      context 'with `create_additions` option' do
        it "registers an offense for `JSON.#{method_name}` with `create_additions` option set to `false`" do
          expect_offense(<<~RUBY, method_name: method_name)
            JSON.#{method_name}(json, create_additions: false).deep_symbolize_keys
            ^^^^^^{method_name}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `symbolize_names` option.
          RUBY
        end

        it "does not register for `JSON.#{method_name}` with `create_additions` option set to `true`" do
          expect_no_offenses(<<~RUBY)
            JSON.#{method_name}(json, create_additions: true).deep_symbolize_keys
          RUBY
        end
      end
    end
  end
end
