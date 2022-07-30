# frozen_string_literal: true

RSpec.shared_context 'with SchemaLoader' do
  let(:schema_path) do
    f = Tempfile.create("rubocop-rails-#{described_class}-test-")
    f.close
    Pathname(f.path)
  end

  before do
    RuboCop::Rails::SchemaLoader.reset!
    schema_path.write(schema)
    allow(RuboCop::Rails::SchemaLoader).to receive(:db_schema_path).and_return(schema_path)
  end

  after do
    RuboCop::Rails::SchemaLoader.reset!
    schema_path.unlink
  end
end
