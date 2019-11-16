# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EngineApiViolation do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      'Rails/EngineApiViolation' => config_params
    )
  end

  let(:config_params) do
    {
      'UnprotectedEngines' => %w[
        UnprotectedEngine
        unprotected_engine_snake_case
      ],
      'EnginesPath' => 'engines'
    }
  end

  let(:api_path) { 'engines/my_engine/app/api/my_engine/api/' }
  let(:legacy_dependents_file) { api_path + '_legacy_dependents.rb' }
  let(:whitelist_file) { api_path + '_whitelist.rb' }

  before do
    allow(Dir).to(
      receive(:[])
        .with('engines/*')
        .and_return([
                      'engines/my_engine',
                      'engines/other_engine',
                      'engines/generic_name',
                      'engines/unprotected_engine'
                    ])
    )
    allow(File).to(
      receive(:file?).with(/_legacy_dependents/).and_return(false)
    )
    allow(File).to(
      receive(:file?).with(/_whitelist/).and_return(false)
    )
  end

  context 'method call on the constant itself' do
    context 'when constructor' do
      let(:source) do
        <<~RUBY
          GenericName.new
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source)
      end
    end

    context 'when random method' do
      let(:source) do
        <<~RUBY
          GenericName.from_foo_bar
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source)
      end
    end

    context 'when namepsaced not engine leading ::' do
      let(:source) do
        <<~RUBY
          ::Types::GenericName.from_foo
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source)
      end
    end

    context 'when namepsaced not engine' do
      let(:source) do
        <<~RUBY
          Types::GenericName.from_foo
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source)
      end
    end
  end

  context 'when going through interface' do
    let(:source) do
      <<~RUBY
        class Controller < ApplicationController
          def foo
            MyEngine::Api.foo
            MyEngine::Api::Nested.foo
            EndsWithMyEngine::NoApi.foo
            res = MyEngine::Api::NestedClass
          end
        end
      RUBY
    end

    it 'does not add any offenses' do
      expect_no_offenses(source)
    end
  end

  context 'when module declaration' do
    let(:source) do
      <<~RUBY
        module Mutations
          module GenericName
            module Foo
              class Bar < Mutations::BaseMutation
                def baz
                  1
                end
              end
            end
          end
        end
      RUBY
    end

    it 'does not add any offenses' do
      expect_no_offenses(source)
    end
  end

  context 'when top-level module declaration' do
    let(:source) do
      <<~RUBY
        module OtherEngine::Constants::Countries::Usa
          FOO = "bar"
        end
      RUBY
    end

    it 'does not add any offenses' do
      expect_no_offenses(source)
    end
  end

  context 'when unprotected engine' do
    let(:source) do
      <<~RUBY
        class Controller < ApplicationController
          def foo
            UnprotectedEngine::NoApi.foo
          end
        end
      RUBY
    end

    it 'does not add any offenses' do
      expect_no_offenses(source)
    end
  end

  context 'when unprotected engine' do
    let(:source) do
      <<~RUBY
        class Controller < ApplicationController
          def foo
            UnprotectedEngineSnakeCase::NoApi.foo
          end
        end
      RUBY
    end

    it 'does not add any offenses' do
      expect_no_offenses(source)
    end
  end

  context 'when inside engine' do
    let(:file) do
      '/root/engines/my_engine/app/controllers/my_engine/foo_controller.rb'
    end
    let(:source) do
      <<~RUBY
        module MyEngine
          class FooController
          end
        end
        class MyEngine::NestedController < MyEngine::FooController
        end
      RUBY
    end

    it 'does not add any offenses' do
      expect_no_offenses(source, file)
    end
  end

  context 'when class has same name as engine' do
    let(:source) do
      <<~RUBY
        module Foo
          class MyEngine
            def bar
              1
            end
          end
        end
      RUBY
    end

    it 'does not add any offenses' do
      expect_no_offenses(source)
    end
  end

  context 'when non-engine association' do
    let(:source) do
      <<~RUBY
        class Foo < ApplicationModel
          has_one :bar, class_name: "Bar", inverse_of: :foo
        end
      RUBY
    end

    it 'does not add any offenses' do
      expect_no_offenses(source)
    end
  end

  context 'Reaching into an engine' do
    describe 'with no leading ::' do
      let(:source) do
        <<~RUBY
          class Controller < ApplicationController
            def foo
              MyEngine::Model.new
              ^^^^^^^^ Direct access of MyEngine engine. Only access engine via MyEngine::Api.
              MyEngine::NoApi::Nested.foo
              ^^^^^^^^ Direct access of MyEngine engine. Only access engine via MyEngine::Api.
              res = MyEngine::NestedClass
                    ^^^^^^^^ Direct access of MyEngine engine. Only access engine via MyEngine::Api.
              MyEngine
              ^^^^^^^^ Direct access of MyEngine engine. Only access engine via MyEngine::Api.
            end
          end
        RUBY
      end

      it 'adds an offense' do
        expect_offense(source)
      end
    end

    describe 'with leading ::' do
      let(:source) do
        <<~RUBY
          class Controller < ApplicationController
            def foo
              ::MyEngine::Model.new
              ^^^^^^^^^^ Direct access of MyEngine engine. Only access engine via MyEngine::Api.
              ::MyEngine::NoApi::Nested.foo
              ^^^^^^^^^^ Direct access of MyEngine engine. Only access engine via MyEngine::Api.
              res = ::MyEngine::NestedClass
                    ^^^^^^^^^^ Direct access of MyEngine engine. Only access engine via MyEngine::Api.
              ::MyEngine
              ^^^^^^^^^^ Direct access of MyEngine engine. Only access engine via MyEngine::Api.
            end
          end
        RUBY
      end

      it 'adds an offense' do
        expect_offense(source)
      end
    end

    describe 'cross-engine association' do
      let(:source) do
        <<~RUBY
          class Foo < ApplicationModel
            has_one :delivery, class_name: "MyEngine::MyModel", inverse_of: :foo
                                           ^^^^^^^^^^^^^^^^^^^ Direct access of MyEngine engine. Only access engine via MyEngine::Api.
          end
        RUBY
      end

      it 'adds an offense' do
        expect_offense(source)
      end
    end
  end

  context 'when whitelist defined' do
    let(:whitelist_source) do
      <<~RUBY
        module MyEngine::Api::Whitelist
          PUBLIC_MODULES = [
            MyEngine::WhitelistedModule,
          ]
        end
      RUBY
    end

    before do
      allow(File).to(
        receive(:file?)
          .with(whitelist_file)
          .and_return(true)
      )
      allow(File).to(
        receive(:read)
          .with(whitelist_file)
          .and_return(whitelist_source)
      )
    end

    context 'when whitelisted public service' do
      let(:source) do
        <<~RUBY
          class Controller < ApplicationController
            def foo
              MyEngine::WhitelistedModule.bar
            end
          end
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source)
      end
    end

    context 'when whitelisted public constant' do
      let(:source) do
        <<~RUBY
          class Controller < ApplicationController
            def foo
              MyEngine::WhitelistedModule::CRUX
            end
          end
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source)
      end
    end

    context 'when whitelisted method accessed with leading :: and expect' do
      let(:source) do
        <<~RUBY
          expect(::MyEngine::WhitelistedModule).to_not receive(:foo)
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source)
      end
    end

    context 'when whitelisted public constant in array' do
      let(:source) do
        <<~RUBY
          class Controller < ApplicationController
            def foo
              if [
                MyEngine::WhitelistedModule::NOT_MANIFESTED,
              ]
                1
              end
            end
          end
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source)
      end
    end
  end

  context 'when whitelist defined' do
    let(:legacy_dependents_source) do
      <<~RUBY
        module MyEngine::Api::LegacyDependents
          FILES_WITH_DIRECT_ACCESS = [
            "app/models/some_old_legacy_model.rb",
            "engines/other_engine/app/services/other_engine/other_service.rb",
          ]
        end
      RUBY
    end

    before do
      allow(File).to(
        receive(:file?)
          .with(legacy_dependents_file)
          .and_return(true)
      )
      allow(File).to(
        receive(:read)
          .with(legacy_dependents_file)
          .and_return(legacy_dependents_source)
      )
    end

    context 'when in legacy dependent file' do
      let(:file) { '/root/app/models/some_old_legacy_model.rb' }
      let(:source) do
        <<~RUBY
          class Controller < ApplicationController
            def foo
              MyEngine::SomethingPrivateFoo.bar
            end
          end
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source, file)
      end
    end
  end

  describe '#external_dependency_checksum' do
    it 'returns a string' do
      expect(cop.external_dependency_checksum.is_a?(String)).to be(true)
    end
  end
end
