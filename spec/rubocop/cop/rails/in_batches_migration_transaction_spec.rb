# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::InBatchesMigrationTransaction, :config do
  %i[up down change].each do |method_name|
    context "when using in_batches in a #{method_name} method" do
      context 'without disable_ddl_transaction!' do
        it 'registers an offense when using in_batches with update_all' do
          expect_offense(<<~RUBY)
            class SomeMigration < ActiveRecord::Migration[8.0]
              def #{method_name}
                Model.in_batches.update_all(active: true)
                ^^^^^^^^^^^^^^^^ Do not use `in_batches` without `disable_ddl_transaction!` in migrations.
              end
            end
          RUBY
        end

        it 'registers an offense when using in_batches with enumeration' do
          expect_offense(<<~RUBY)
            class SomeMigration < ActiveRecord::Migration[8.0]
              def #{method_name}
                Model.in_batches.each do |relation|
                ^^^^^^^^^^^^^^^^ Do not use `in_batches` without `disable_ddl_transaction!` in migrations.
                  # some batch processing here, e.g. relation.update_all(active: true)
                end
              end
            end
          RUBY
        end
      end

      context 'with disable_ddl_transaction!' do
        it 'does not register an offense when using in_batches with update_all' do
          expect_no_offenses(<<~RUBY)
            class SomeMigration < ActiveRecord::Migration[8.0]
              disable_ddl_transaction!

              def #{method_name}
                Model.in_batches.update_all(active: true)
              end
            end
          RUBY
        end

        it 'does not register an offense when using in_batches with enumeration' do
          expect_no_offenses(<<~RUBY)
            class SomeMigration < ActiveRecord::Migration[8.0]
              disable_ddl_transaction!

              def #{method_name}
                Model.in_batches.each do |relation|
                  # some batch processing here, e.g. relation.update_all(active: true)
                end
              end
            end
          RUBY
        end
      end
    end
  end
end
