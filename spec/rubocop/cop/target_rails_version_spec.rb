# frozen_string_literal: true

RSpec.describe RuboCop::Cop::TargetRailsVersion do
  include FileHelper

  let(:loaded_path) { 'example/.rubocop.yml' }

  describe '.resolve' do
    subject(:resolved_version) { described_class.resolve(configuration) }

    let(:configuration) { RuboCop::Config.new(hash, loaded_path) }

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

        it 'truncates the patch part and converts to a float' do
          expect(resolved_version).to eq 5.1
        end
      end

      context 'correctly' do
        let(:rails_version) { 6.0 }

        it 'uses TargetRailsVersion' do
          expect(resolved_version).to eq rails_version
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
          expect(resolved_version).to eq described_class::DEFAULT_RAILS_VERSION
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
            expect(resolved_version).to eq 4.1
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
            expect(resolved_version).to eq 400.33
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
            expect(resolved_version).not_to eq 900.88
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
            expect(resolved_version).to eq described_class::DEFAULT_RAILS_VERSION
          end
        end
      end
    end
  end

  describe 'version gating for cops using `minimum_target_rails_version`' do
    subject(:satisfied) { cop.send(:target_satisfies_all_gem_version_requirements?) }

    include_context 'maintain registry'

    let(:cop_class) do
      stub_cop_class('RuboCop::Cop::Test::VersionGatedCop') do
        # `described_class` is unavailable here because this block is class-evaled.
        extend RuboCop::Cop::TargetRailsVersion # rubocop:disable RSpec/DescribedClass

        minimum_target_rails_version 7.1
      end
    end
    let(:cop) { cop_class.new(configuration) }

    context 'when TargetRailsVersion satisfies the requirement and no lockfile exists', :isolated_environment do
      let(:configuration) do
        RuboCop::Config.new({ 'AllCops' => { 'TargetRailsVersion' => 7.1 } }, loaded_path)
      end

      it { is_expected.to be(true) }
    end

    context 'when TargetRailsVersion is below the requirement and the lockfile `railties` satisfies it' do
      let(:configuration) do
        configuration = RuboCop::Config.new({ 'AllCops' => { 'TargetRailsVersion' => 5.0 } }, loaded_path)
        allow(configuration).to receive(:gem_versions_in_target).and_return({ 'railties' => Gem::Version.new('7.1.0') })
        configuration
      end

      it { is_expected.to be(false) }
    end

    context 'when TargetRailsVersion is not set and the lockfile `railties` satisfies the requirement' do
      let(:configuration) do
        configuration = RuboCop::Config.new({ 'AllCops' => {} }, loaded_path)
        allow(configuration).to receive(:gem_versions_in_target).and_return({ 'railties' => Gem::Version.new('7.2.0') })
        configuration
      end

      it { is_expected.to be(true) }
    end

    context 'when neither TargetRailsVersion nor a lockfile exists', :isolated_environment do
      let(:configuration) { RuboCop::Config.new({ 'AllCops' => {} }, loaded_path) }

      it { is_expected.to be(false) }
    end

    # The override targets a private method of `RuboCop::Cop::Base`. This example fails loudly
    # when RuboCop core renames it, in which case the override must follow; the behavior examples
    # above cannot catch that because they call the override directly.
    it 'overrides a private method that still exists in RuboCop core' do
      expect(RuboCop::Cop::Base.private_method_defined?(:target_satisfies_all_gem_version_requirements?)).to be(true)
    end
  end
end
