# frozen_string_literal: true

RSpec.describe RuboCop::Rails::SchemaLoader do
  describe '.load' do
    require 'parser/ruby27'
    let(:target_ruby_version) { 2.7 }

    around do |example|
      described_class.reset!
      example.run
      described_class.reset!
    end

    context 'without schema.rb' do
      it do
        expect(described_class.load(target_ruby_version)).to be nil
      end
    end

    context 'with schema.rb' do
      subject(:loaded_schema) do
        described_class.load(target_ruby_version)
      end

      let(:rails_root) { Pathname(Dir.mktmpdir) }
      let(:schema) { <<~RUBY }
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "users", force: :cascade do |t|
            t.string "account", null: false
            t.index ["account"], name: "index_users_on_account", unique: true
          end

          create_table "articles", force: :cascade do |t|
            t.string "title", null: false
            t.bigint "user_id"
            t.index 'lower(title)', name: 'index_title_lower_unique', unique: true
          end
        end
      RUBY

      before do
        rails_root.join('app/models').mkpath
        rails_root.join('db').mkpath
        rails_root.join('db/schema.rb').write(schema)
      end

      after do
        rails_root.rmtree
      end

      shared_examples 'returns a schema' do
        it 'returns a schema' do
          klass = RuboCop::Rails::SchemaLoader::Schema
          expect(loaded_schema.is_a?(klass)).to be(true)
          expect(loaded_schema.tables.size).to eq 2
        end

        it 'has a column in users table' do
          table = loaded_schema.table_by(name: 'users')
          expect(table.name).to eq 'users'
          expect(table.columns.size).to eq 1
          expect(table.columns.first.name).to eq 'account'
          expect(table.columns.first.not_null).to be true
        end

        it 'has an index in users table' do
          table = loaded_schema.table_by(name: 'users')
          expect(table.indices.size).to eq 1
          expect(table.indices.first.name).to eq 'index_users_on_account'
          expect(table.indices.first.columns).to eq ['account']
          expect(table.indices.first.unique).to be true
        end

        it 'has articles table' do
          table = loaded_schema.table_by(name: 'articles')
          expect(table.name).to eq 'articles'

          expect(table.columns.size).to eq 2
          expect(table.columns.last.type).to eq :bigint
        end

        it 'has an index in articles table' do
          table = loaded_schema.table_by(name: 'articles')
          expect(table.indices.size).to eq 1
          expect(table.indices.first.name).to eq 'index_title_lower_unique'
          expect(table.indices.first.unique).to be true
        end
      end

      context 'when the current directory is Rails.root' do
        before do
          allow(Pathname).to receive(:pwd).and_return(rails_root)
        end

        it_behaves_like 'returns a schema'
      end

      context 'when the current directory is a sub-directory of Rails.root' do
        before do
          allow(Pathname).to receive(:pwd)
            .and_return(rails_root.join('app/models'))
        end

        it_behaves_like 'returns a schema'
      end
    end
  end
end
