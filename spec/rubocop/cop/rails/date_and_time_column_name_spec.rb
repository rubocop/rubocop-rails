# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DateAndTimeColumnName, :config do
  described_class::TYPE_TO_SUFFIX.each do |type, suffix|
    context 'when `add_column` method' do
      it "registers an offense for `#{type}` column without `#{suffix}` suffix" do
        source = <<~RUBY
          class AddColumnNameToTableName < ActiveRecord::Migration[6.0]
            def change
              add_column :table_name, :column_name_without_suffix, :#{type}
            end
          end
        RUBY

        offenses = inspect_source(source)
        expect(offenses.count).to eq(1)
      end

      it "does not register an offense for `#{type}` column with `#{suffix}` suffix" do
        expect_no_offenses(<<~RUBY)
          class AddColumnNameToTableName < ActiveRecord::Migration[6.0]
            def change
              add_column :table_name, :column_name_#{suffix}, :#{type}
            end
          end
        RUBY
      end
    end

    context 'when `column` method' do
      it "registers an offense for `#{type}` column without `#{suffix}` suffix" do
        source = <<~RUBY
          class AddColumnNameToTableName < ActiveRecord::Migration[6.0]
            def change
              create_table :table_name do |t|
                t.column :column_name_without_suffix, :#{type}
              end
            end
          end
        RUBY

        offenses = inspect_source(source)
        expect(offenses.count).to eq(1)
      end

      it "does not register an offense for `#{type}` column with `#{suffix}` suffix" do
        expect_no_offenses(<<~RUBY)
          class AddColumnNameToTableName < ActiveRecord::Migration[6.0]
            def change
              create_table :table_name do |t|
                t.column :column_name_#{suffix}, :#{type}
              end
            end
          end
        RUBY
      end

      it 'does not register an offense when non date column is used' do
        expect_no_offenses(<<~RUBY)
          class AddColumnNameToTableName < ActiveRecord::Migration[6.0]
            def change
              create_table :table_name do |t|
                t.column :column_name, :integer
              end
            end
          end
        RUBY
      end
    end

    context 'when `t.<type>` method' do
      it "registers an offense for `#{type}` column without `#{suffix}` suffix" do
        source = <<~RUBY
          class AddColumnNameToTableName < ActiveRecord::Migration[6.0]
            def change
              create_table :table_name do |t|
                t.#{type} :column_name_without_suffix
              end
            end
          end
        RUBY

        offenses = inspect_source(source)
        expect(offenses.count).to eq(1)
      end

      it "does not register an offense for `#{type}` column with `#{suffix}` suffix" do
        expect_no_offenses(<<~RUBY)
          class AddColumnNameToTableName < ActiveRecord::Migration[6.0]
            def change
              create_table :table_name do |t|
                t.#{type} :column_name_#{suffix}
              end
            end
          end
        RUBY
      end

      it 'does not register an offense when non date column is used' do
        expect_no_offenses(<<~RUBY)
          class AddColumnNameToTableName < ActiveRecord::Migration[6.0]
            def change
              create_table :table_name do |t|
                t.integer :column_name
              end
            end
          end
        RUBY
      end
    end
  end

  it 'does not register an offense when `add_column` with non date column is used' do
    expect_no_offenses(<<~RUBY)
      class AddColumnNameToTableName < ActiveRecord::Migration[6.0]
        def change
          add_column :table_name, :column_name, :integer
        end
      end
    RUBY
  end

  it 'does not register an offense when not inside migration' do
    expect_no_offenses(<<~RUBY)
      class Foo
        add_column :table_name, :column_name, :datetime
      end
    RUBY
  end

  context 'MigratedSchemaVersion is used' do
    let(:config) do
      RuboCop::Config.new('AllCops' => { 'MigratedSchemaVersion' => '20211007000001' })
    end

    it 'registers an offense for newer migrations' do
      expect_offense(<<~RUBY, 'db/migrate/20211007000002_add_created_on_to_orders.rb')
        class AddCreatedOnToOrders < ActiveRecord::Migration[6.0]
          def change
            add_column :orders, :created_on, :datetime
                                ^^^^^^^^^^^ Name `datetime` columns with `_at` suffixes.
          end
        end
      RUBY
    end

    it 'does not register an offense for older migrations' do
      expect_no_offenses(<<~RUBY, 'db/migrate/20211007000001_add_column_to_table_name.rb')
        class AddCreatedOnToOrders < ActiveRecord::Migration[6.0]
          def change
            add_column :orders, :created_on, :datetime
          end
        end
      RUBY
    end
  end
end
