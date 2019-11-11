# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::NewGlobalModel do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      'Rails/NewGlobalModel' => {
        'GlobalModelsPath' => 'app/models/',
        'AllowNamespacedGlobalModels' => true
      }
    )
  end

  context 'when non-model file' do
    let(:random_file) { '/root/bar/random.rb' }

    let(:source) do
      <<~RUBY
        module RandomFile
          FOO = 1
        end
      RUBY
    end

    it 'does not add any offenses' do
      expect_no_offenses(source, random_file)
    end
  end

  context 'engine models' do
    context 'when model in engine' do
      let(:engine_model_file) do
        '/root/engines/my_engine/app/models/my_engine/model_in_engine.rb'
      end

      let(:source) do
        <<~RUBY
          class GlobalModelInEngine
            FOO = 1
          end
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source, engine_model_file)
      end
    end

    context 'when model in engine without /engines/ in path' do
      let(:atypical_engine_model_file) do
        '/root/radiators/my_engine/app/models/my_engine/model_in_engine.rb'
      end

      let(:source) do
        <<~RUBY
          class GlobalModelInEngine
            FOO = 1
          end
        RUBY
      end

      it 'does not add any offenses' do
        expect_no_offenses(source, atypical_engine_model_file)
      end
    end
  end

  context 'global models' do
    context 'when new global model file' do
      let(:global_model_file) { '/root/app/models/new_global_model.rb' }

      let(:source) do
        <<~RUBY
          class NewGlobalModel
          ^^^^^^^^^^^^^^^^^^^^ Do not add new top-level global models in `app/models`. Prefer namespaced models like `app/models/foo/bar.rb` or or models inside Rails Engines.
            FOO = 1
          end
        RUBY
      end

      it 'adds offenses' do
        expect_offense(source, global_model_file)
      end
    end

    context 'when model in subdir' do
      let(:global_model_file_in_sub_dir) { '/root/app/models/foo/bar.rb' }

      context 'AllowNamespacedGlobalModels is true' do
        let(:source) do
          <<~RUBY
            class Foo::Bar
              FOO = 1
            end
          RUBY
        end

        it 'does not add any offenses' do
          expect_no_offenses(source, global_model_file_in_sub_dir)
        end
      end

      context 'AllowNamespacedGlobalModels is false' do
        let(:config) do
          RuboCop::Config.new(
            'Rails/NewGlobalModel' => {
              'GlobalModelsPath' => 'app/models/',
              'AllowNamespacedGlobalModels' => false
            }
          )
        end

        let(:source) do
          <<~RUBY
            class Foo::Bar
            ^^^^^^^^^^^^^^ Do not add new global models in `app/models`. Instead add new models to Rails Engines.
              FOO = 1
            end
          RUBY
        end

        it 'adds offenses' do
          expect_offense(source, global_model_file_in_sub_dir)
        end
      end
    end
  end
end
