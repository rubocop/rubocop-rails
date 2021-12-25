# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DateAndTimeColumnName do
  subject(:cop) { described_class.new }

  context 'when `add_column` method' do
    described_class::TYPE_TO_SUFFIX.each do |type, suffix|
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

    it 'does not register an offense when non date column is used' do
      expect_no_offenses(<<~RUBY)
        class AddColumnNameToTableName < ActiveRecord::Migration[6.0]
          def change
            add_column :table_name, :column_name, :integer
          end
        end
      RUBY
    end
  end

  context 'when `column` method' do
    described_class::TYPE_TO_SUFFIX.each do |type, suffix|
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
  end

  context 'when `<type>` method' do
    described_class::TYPE_TO_SUFFIX.each do |type, suffix|
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

  it 'does not register an offense when not inside migration' do
    expect_no_offenses(<<~RUBY)
      class Foo
        add_column :table_name, :column_name, :datetime
      end
    RUBY
  end
end
