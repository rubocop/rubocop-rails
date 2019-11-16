# frozen_string_literal: true

RSpec.describe RuboCop::Cop::EngineApi do
  class TestEngineApi
    include RuboCop::Cop::EngineApi
  end

  let(:cop) { TestEngineApi.new }

  let(:engines_path) { 'engines/' }

  let(:api_files) do
    [
      'engines/foo/app/api/foo/api/abc.rb',
      'engines/foo/app/api/foo/api/_whitelist.rb',
      'engines/bar/app/api/bar/api/def.rb'
    ]
  end

  before do
    allow(Dir).to(
      receive(:glob)
        .with('engines/**/app/api/**/api/**/*')
        .and_return(api_files)
    )
    allow(File).to(
      receive(:mtime)
        .with(%r{app/api})
        .and_return('2019-11-11 16:24:47 -0600')
    )
  end

  describe '#engine_api_files_modified_time_checksum' do
    it 'returns a string' do
      result = cop.engine_api_files_modified_time_checksum(engines_path)
      expect(result.is_a?(String)).to be(true)
    end

    context 'file modified time does not changes' do
      it 'returns same checksum' do
        first = cop.engine_api_files_modified_time_checksum(engines_path)
        second = cop.engine_api_files_modified_time_checksum(engines_path)
        expect(first).to eq(second)
      end
    end

    context 'file modified time changes' do
      it 'returns different checksum' do
        old_result = cop.engine_api_files_modified_time_checksum(engines_path)
        allow(File).to(
          receive(:mtime)
            .with('engines/foo/app/api/foo/api/_whitelist.rb')
            .and_return('2020-11-11 16:24:47 -0600')
        )
        new_result = cop.engine_api_files_modified_time_checksum(engines_path)
        expect(old_result).not_to eq(new_result)
      end
    end

    context 'new file added' do
      let(:new_file) do
        'engines/bar/app/api/bar/api/_legacy_dependents.rb'
      end

      it 'returns different checksum' do
        old_result = cop.engine_api_files_modified_time_checksum(engines_path)
        allow(Dir).to(
          receive(:glob)
            .with('engines/**/app/api/**/api/**/*')
            .and_return(api_files.append(new_file))
        )
        new_result = cop.engine_api_files_modified_time_checksum(engines_path)
        expect(old_result).not_to eq(new_result)
      end
    end

    context 'files are removed' do
      let(:new_file) do
        'engines/bar/app/api/bar/api/_legacy_dependents.rb'
      end

      it 'returns different checksum' do
        old_result = cop.engine_api_files_modified_time_checksum(engines_path)
        allow(Dir).to(
          receive(:glob)
            .with('engines/**/app/api/**/api/**/*')
            .and_return([api_files.first])
        )
        new_result = cop.engine_api_files_modified_time_checksum(engines_path)
        expect(old_result).not_to eq(new_result)
      end
    end
  end
end
