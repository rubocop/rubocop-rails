# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EngineGlobalModelAccess, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      'Rails/EngineGlobalModelAccess' => {
        'DisabledEngines' => %w[
          fake_disabled_engine
          FakeDisabledEngineCamel
        ],
        'EnginesPath' => 'engines',
        'GlobalModelsPath' => 'app/models/',
        'AllowedGlobalModels' => ['WhitelistedGlobalModel']
      }
    )
  end

  let(:engine_file) { '/root/engines/my_engine/app/file.rb' }

  before do
    allow(Dir).to(
      receive(:[])
        .with('app/models/**/*.rb')
        .and_return([
                      'app/models/some_global_model.rb',
                      'app/models/nested/global_model.rb'
                    ])
    )
  end

  context 'no violation' do
    describe 'disabled engine' do
      let(:disabled_engine_file) do
        '/root/engines/fake_disabled_engine/app/file.rb'
      end
      let(:source) do
        <<~RUBY
          SomeGlobalModel.find(123)
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source, disabled_engine_file)
      end
    end

    describe 'disabled engine camel case' do
      let(:disabled_engine_file) do
        '/root/engines/fake_disabled_engine_camel/app/file.rb'
      end
      let(:source) do
        <<~RUBY
          SomeGlobalModel.find(123)
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source, disabled_engine_file)
      end
    end

    describe 'just accessing a const' do
      let(:source) do
        <<~RUBY
          a = SomeGlobalModel::SOME_CONST
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source, engine_file)
      end
    end

    describe 'file in app/ outside engine' do
      let(:non_engine_file) { '/root/app/file.rb' }
      let(:source) do
        <<~RUBY
          SomeGlobalModel.find(123)
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source, non_engine_file)
      end
    end

    describe 'with whitelisted global model' do
      let(:source) do
        <<~RUBY
          WhitelistedGlobalModel.find(123)
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source, engine_file)
      end
    end

    describe 'association to global model in app/' do
      let(:non_engine_file) { '/root/app/models/bar.rb' }
      let(:source) do
        <<~RUBY
          class Bar < ApplicationModel
            has_one :some_global_model, class_name: "SomeGlobalModel", inverse_of: :bar
          end
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source, non_engine_file)
      end
    end

    describe 'association to other engine model' do
      let(:source) do
        <<~RUBY
          class MyEngine::Foo < ApplicationModel
            has_one :bar, class_name: "SomeOtherEngine::Bar", inverse_of: :foo
          end
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source, engine_file)
      end
    end
  end

  context 'violation' do
    describe 'access of global model from engine' do
      let(:source) do
        <<~RUBY
          SomeGlobalModel.find(123)
          ^^^^^^^^^^^^^^^ Direct access of global model from within Rails Engine.
        RUBY
      end

      it 'adds an offense' do
        expect_offense(source, engine_file)
      end
    end

    describe 'association to global model' do
      let(:source) do
        <<~RUBY
          class MyEngine::Foo < ApplicationModel
            has_one :some_global_model, class_name: "SomeGlobalModel", inverse_of: :foo
                                                    ^^^^^^^^^^^^^^^^^ Direct access of global model from within Rails Engine.
          end
        RUBY
      end

      it 'adds an offense' do
        expect_offense(source, engine_file)
      end
    end

    context 'nested global model' do
      describe 'access of global model from engine' do
        let(:source) do
          <<~RUBY
            Nested::GlobalModel.find(123)
            ^^^^^^^^^^^^^^^^^^^ Direct access of global model from within Rails Engine.
          RUBY
        end

        it 'adds an offense' do
          expect_offense(source, engine_file)
        end
      end

      describe 'association to global model' do
        let(:source) do
          <<~RUBY
            class MyEngine::FooModel < ApplicationModel
              has_one :nested_global_model, class_name: "Nested::GlobalModel", inverse_of: :foo
                                                        ^^^^^^^^^^^^^^^^^^^^^ Direct access of global model from within Rails Engine.
            end
          RUBY
        end

        it 'adds an offense' do
          expect_offense(source, engine_file)
        end
      end
    end
  end

  describe '#external_dependency_checksum' do
    it 'differs based on contents of app/models dir' do
      old_checksum = cop.external_dependency_checksum
      allow(Dir).to(
        receive(:[])
          .with('app/models/**/*.rb')
          .and_return(['app/models/nested/global_model.rb'])
      )
      new_checksum = cop.external_dependency_checksum
      expect(new_checksum).not_to equal(old_checksum)
    end
  end
end
