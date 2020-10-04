# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::CalendarTypeSuffix, :config do
  subject(:cop) do
    cop = described_class.new(config)
    allow(cop).to receive(:relevant_file?).and_return(true)
    cop
  end

  let(:schema_path) do
    f = Tempfile.create('rubocop-rails-CalendarTypeSuffix-test-')
    f.close
    Pathname(f.path)
  end

  let(:cop_config) do
    {
      'DateSuffix' => 'on',
      'DateTimeSuffix' => 'at',
      'TimeSuffix' => 'time'
    }
  end

  before do
    RuboCop::Rails::SchemaLoader.reset!
    schema_path.write(schema)
    allow(RuboCop::Rails::SchemaLoader).to receive(:db_schema_path)
      .and_return(schema_path)
  end

  after do
    RuboCop::Rails::SchemaLoader.reset!
    schema_path.unlink
  end

  context 'when calendar type columns do no follow the conventional suffixes' do
    let(:schema) { <<~RUBY }
      ActiveRecord::Schema.define(version: 2020_02_02_075409) do
        create_table "users", force: :cascade do |t|
          t.date "sign_up", null: false
          t.datetime "last_login"
          t.time "lock_until"
        end
      end
    RUBY

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ActiveRecord::Schema.define(version: 2020_02_02_075409) do
          create_table "users", force: :cascade do |t|
            t.date "sign_up", null: false
            ^^^^^^^^^^^^^^^^ Columns of type `date` should be named with a `on` suffix.
            t.datetime "last_login"
            ^^^^^^^^^^^^^^^^^^^^^^^ Columns of type `datetime` should be named with a `at` suffix.
            t.time "lock_until"
            ^^^^^^^^^^^^^^^^^^^ Columns of type `time` should be named with a `time` suffix.
          end
        end
      RUBY
    end
  end

  context 'when calendar type columns follow the conventional suffixes' do
    let(:schema) { <<~RUBY }
      ActiveRecord::Schema.define(version: 2020_02_02_075409) do
        create_table "users", force: :cascade do |t|
          t.date "signed_up_on", null: false
          t.datetime "last_login_at"
          t.time "locked_until_time"
        end
      end
    RUBY

    it 'does not register an offense' do
      expect_no_offenses(schema)
    end
  end
end
