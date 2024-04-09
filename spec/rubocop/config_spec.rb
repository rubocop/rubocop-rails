# frozen_string_literal: true

RSpec.describe RuboCop::Config do
  include FileHelper

  subject(:configuration) { described_class.new(hash, loaded_path) }

  let(:loaded_path) { 'example/.rubocop.yml' }

  describe '#target_rails_version' do
    context 'when TargetRailsVersion is set' do
      let(:hash) do
        {
          'AllCops' => {
            'TargetRailsVersion' => rails_version
          }
        }
      end

      context 'with patch version' do
        let(:rails_version) { '5.1.4' }
        let(:rails_version_to_f) { 5.1 }

        it 'truncates the patch part and converts to a float' do
          expect(configuration.target_rails_version).to eq rails_version_to_f
        end
      end

      context 'correctly' do
        let(:rails_version) { 6.0 }

        it 'uses TargetRailsVersion' do
          expect(configuration.target_rails_version).to eq rails_version
        end
      end
    end

    context 'when TargetRailsVersion is not set', :isolated_environment do
      let(:hash) do
        {
          'AllCops' => {}
        }
      end

      context 'and lock files do not exist' do
        it 'uses the default rails version' do
          default = described_class::DEFAULT_RAILS_VERSION
          expect(configuration.target_rails_version).to eq default
        end
      end

      ['Gemfile.lock', 'gems.locked'].each do |file_name|
        context "and #{file_name} exists" do
          let(:base_path) { configuration.base_dir_for_path_parameters }
          let(:lock_file_path) { File.join(base_path, file_name) }

          it "uses the single digit Rails version in #{file_name}" do
            content =
              <<~LOCKFILE
                GEM
                  remote: https://rubygems.org/
                  specs:
                    actionmailer (4.1.0)
                    actionpack (4.1.0)
                    actionview (4.1.0)
                    mail (2.5.4)
                    rails (4.1.0)
                      actionmailer (= 4.1.0)
                      actionpack (= 4.1.0)
                      actionview (= 4.1.0)
                      activemodel (= 4.1.0)
                      activerecord (= 4.1.0)
                      activesupport (= 4.1.0)
                      bundler (>= 1.3.0, < 2.0)
                      railties (= 4.1.0)
                      sprockets-rails (~> 2.0)
                    railties (4.1.0)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  rails (= 4.1.0)

                BUNDLED WITH
                  1.16.1
              LOCKFILE
            create_file(lock_file_path, content)
            expect(configuration.target_rails_version).to eq 4.1
          end

          it "uses the multi digit Rails version in #{file_name}" do
            content =
              <<~LOCKFILE
                GEM
                  remote: https://rubygems.org/
                  specs:
                    actionmailer (4.1.0)
                    actionpack (4.1.0)
                    actionview (4.1.0)
                    mail (2.5.4)
                    rails (400.33.22)
                      actionmailer (= 4.1.0)
                      actionpack (= 4.1.0)
                      actionview (= 4.1.0)
                      activemodel (= 4.1.0)
                      activerecord (= 4.1.0)
                      activesupport (= 4.1.0)
                      bundler (>= 1.3.0, < 2.0)
                      railties (= 4.1.0)
                      sprockets-rails (~> 2.0)
                    railties (400.33.22)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  rails (= 900.88.77)

                BUNDLED WITH
                  1.16.1
              LOCKFILE
            create_file(lock_file_path, content)
            expect(configuration.target_rails_version).to eq 400.33
          end

          it "does not use the DEPENDENCIES Rails version in #{file_name}" do
            content =
              <<~LOCKFILE
                GEM
                  remote: https://rubygems.org/
                  specs:
                    actionmailer (4.1.0)
                    actionpack (4.1.0)
                    actionview (4.1.0)
                    mail (2.5.4)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  rails (= 900.88.77)

                BUNDLED WITH
                  1.16.1
              LOCKFILE
            create_file(lock_file_path, content)
            expect(configuration.target_rails_version).not_to eq 900.88
          end

          it "uses the default Rails when Rails is not in #{file_name}" do
            content =
              <<~LOCKFILE
                GEM
                  remote: https://rubygems.org/
                  specs:
                    addressable (2.5.2)
                      public_suffix (>= 2.0.2, < 4.0)
                    ast (2.4.0)
                    bump (0.5.4)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  bump
                  bundler (~> 1.3)

                BUNDLED WITH
                  1.16.1
              LOCKFILE
            create_file(lock_file_path, content)
            default = described_class::DEFAULT_RAILS_VERSION
            expect(configuration.target_rails_version).to eq default
          end
        end
      end
    end
  end
end
