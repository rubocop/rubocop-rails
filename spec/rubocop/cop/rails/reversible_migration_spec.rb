# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ReversibleMigration, :config do
  let(:config) do
    RuboCop::Config.new(
      'AllCops' => { 'MigratedSchemaVersion' => '20240101010101', 'TargetRailsVersion' => rails_version }
    )
  end
  let(:source) do
    <<~RUBY
      class ExampleMigration < ActiveRecord::Migration[7.0]
        def change
          #{code}
        end
      end
    RUBY
  end

  shared_examples 'accepts' do |name, code|
    let(:code) { code }

    it "accepts usages of #{name}" do
      expect_no_offenses(source)
    end
  end

  shared_examples 'offense' do |name, code|
    let(:code) { code }

    it "registers an offense for #{name}" do
      offenses = inspect_source(source)

      expect(offenses.first.message).to eq("#{name} is not reversible.")
    end
  end

  it_behaves_like 'accepts', 'create_table', <<~RUBY
    create_table :users do |t|
      t.string :name
    end
  RUBY

  context 'Ruby >= 2.7', :ruby27 do
    it_behaves_like 'accepts', 'create_table using numbered parameter', <<~RUBY
      create_table :users do
        _1.string :name
      end
    RUBY
  end

  it_behaves_like 'offense', 'execute', <<~RUBY
    execute "ALTER TABLE `pages_linked_pages` ADD UNIQUE `page_id_linked_page_id` (`page_id`,`linked_page_id`)"
  RUBY

  it_behaves_like 'accepts', 'up_only', <<~RUBY
    up_only { execute "UPDATE posts SET published = 'true'" }
  RUBY

  context 'within block' do
    it_behaves_like 'accepts', 'create_table', <<~RUBY
      [:users, :articles].each do |table|
        create_table table do |t|
          t.string :name
        end
      end
    RUBY

    it_behaves_like 'offense', 'execute', <<~RUBY
      [:pages_linked_pages, :pages_unlinked_pages].each do |table|
        execute "ALTER TABLE `table` ADD UNIQUE `page_id_linked_page_id` (`page_id`,`linked_page_id`)"
      end
    RUBY
  end

  context 'when using variable assignment' do
    it_behaves_like 'accepts', 'create_table', <<~RUBY
      def change
        change_table :invoices do |t|
          decimals_params = {precision: 10, scale: 2}

          t.decimal :total_discount, decimals_params
        end
      end
    RUBY
  end

  context 'when block argument is empty' do
    it_behaves_like 'accepts', 'create_table', <<~RUBY
      def change
        change_table :invoices do |t|
        end
      end
    RUBY
  end

  context 'within #reversible' do
    it_behaves_like 'accepts', 'execute', <<~RUBY
      reversible do |dir|
        dir.up do
          execute "ALTER TABLE `pages_linked_pages` ADD UNIQUE `page_id_linked_page_id` (`page_id`,`linked_page_id`)"
        end

        dir.down do
          execute "ALTER TABLE `pages_linked_pages` DROP INDEX `page_id_linked_page_id`"
        end
      end
    RUBY
  end

  context 'drop_table' do
    it_behaves_like 'accepts', 'drop_table(with block)', <<~RUBY
      drop_table :users do |t|
        t.string :name
      end
    RUBY

    it_behaves_like 'accepts', 'drop_table(with symbol proc)', <<~RUBY
      drop_table :users, &:timestamps
    RUBY

    it_behaves_like 'offense', 'drop_table(without block)', <<~RUBY
      drop_table :users
    RUBY
  end

  context 'change_column' do
    it_behaves_like 'accepts', 'up_only', <<~RUBY
      up_only { change_column(:posts, :state, :string) }
    RUBY

    it_behaves_like 'offense', 'change_column', <<~RUBY
      change_column(:posts, :state, :string)
    RUBY

    it_behaves_like 'offense', 'change_column', <<~RUBY
      change_column(:posts, :state, :string, null: false)
    RUBY
  end

  context 'change_column_default' do
    it_behaves_like 'accepts',
                    'change_column_default(with :from and :to)', <<-RUBY
      change_column_default(:posts, :state, from: nil, to: "draft")
    RUBY

    it_behaves_like 'accepts',
                    'change_column_default(with :to and :from)', <<-RUBY
      change_column_default(:posts, :state, to: "draft", from: nil)
    RUBY

    it_behaves_like 'accepts',
                    'change_column_default(*column :from and :to)', <<-RUBY
      columns = [:foo, :bar]
      change_column_default(*columns, from: nil, to: "draft")
    RUBY

    it_behaves_like 'offense',
                    'change_column_default(without :from and :to)', <<-RUBY
      change_column_default(:suppliers, :qualification, 'new')
    RUBY
  end

  context 'change_table_comment' do
    it_behaves_like 'accepts',
                    'change_table_comment(with :from and :to)', <<-RUBY
      change_table_comment(:posts, from: nil, to: "draft")
    RUBY

    it_behaves_like 'offense',
                    'change_table_comment(without :from and :to)', <<-RUBY
      change_table_comment(:suppliers, 'new')
    RUBY
  end

  context 'change_column_comment' do
    it_behaves_like 'accepts',
                    'change_column_comment(with :from and :to)', <<-RUBY
      change_column_comment(:posts, :state, from: nil, to: "draft")
    RUBY

    it_behaves_like 'offense',
                    'change_column_comment(without :from and :to)', <<-RUBY
      change_column_comment(:suppliers, :qualification, 'new')
    RUBY
  end

  context 'remove_column' do
    it_behaves_like 'accepts', 'remove_column(with type)', <<~RUBY
      remove_column(:suppliers, :qualification, :string)
    RUBY

    it_behaves_like 'accepts', 'remove_column(with type and options)', <<~RUBY
      remove_column(:suppliers, :qualification, :string, null: false)
    RUBY

    it_behaves_like 'offense', 'remove_column(without type)', <<~RUBY
      remove_column(:suppliers, :qualification)
    RUBY
  end

  context 'remove_foreign_key' do
    it_behaves_like 'accepts', 'remove_foreign_key(with table)', <<~RUBY
      remove_foreign_key :accounts, :branches
    RUBY

    it_behaves_like 'accepts', 'remove_foreign_key(with :to_table)', <<~RUBY
      remove_foreign_key :accounts, to_table: :branches
    RUBY

    it_behaves_like 'offense', 'remove_foreign_key(without table)', <<~RUBY
      remove_foreign_key :accounts, column: :owner_id
    RUBY
  end

  context 'change_table' do
    it_behaves_like 'accepts', 'change_table(with reversible calls)', <<~RUBY
      change_table :users do |t|
        t.column :name, :string
        t.text :description
        t.boolean :authorized
      end
    RUBY

    it_behaves_like 'offense', 'change_table(with change)', <<~RUBY
      change_table :users do |t|
        t.change :description, :text
      end
    RUBY

    it_behaves_like 'accepts',
                    'change_table(with reversible change_default)', <<-RUBY
      change_table :users do |t|
        t.change_default :authorized, from: nil, to: 1
      end
    RUBY

    it_behaves_like 'offense', 'change_table(with change_default)', <<~RUBY
      change_table :users do |t|
        t.change_default :authorized, 1
      end
    RUBY

    context 'Ruby >= 2.7', :ruby27 do
      it_behaves_like 'offense', 'change_table(with change_default)', <<~RUBY
        change_table :users do
          _1.change_default :authorized, 1
        end
      RUBY
    end

    context 'remove' do
      context 'Rails >= 6.1', :rails61 do
        it_behaves_like 'accepts', 't.remove (with type)', <<~RUBY
          change_table :users do |t|
            t.remove(:posts, type: :text)
          end
        RUBY

        it_behaves_like 'offense', 't.remove (without type)', <<~RUBY
          change_table :users do |t|
            t.remove(:posts)
          end
        RUBY
      end

      context 'Rails < 6.1', :rails60 do
        it_behaves_like 'offense', 't.remove', <<~RUBY
          change_table :users do |t|
            t.remove(:posts, type: :text)
          end
        RUBY

        it_behaves_like 'offense', 't.remove', <<~RUBY
          change_table :users do |t|
            t.remove(:posts)
          end
        RUBY
      end
    end
  end

  context 'remove_columns' do
    context 'Rails >= 6.1', :rails61 do
      it_behaves_like 'accepts', 'remove_columns(with type)', <<~RUBY
        remove_columns(:posts, :title, :body, type: :text)
      RUBY

      it_behaves_like 'offense', 'remove_columns(without type)', <<~RUBY
        remove_columns(:posts, :title, :body)
      RUBY
    end

    context 'Rails < 6.1', :rails60 do
      it_behaves_like 'offense', 'remove_columns', <<~RUBY
        remove_columns(:posts, :title, :body, type: :text)
      RUBY
    end

    it_behaves_like 'offense', 'remove_columns', <<~RUBY
      remove_columns(:posts, :title, :body)
    RUBY
  end

  context 'remove_index' do
    it_behaves_like 'accepts', 'remove_index (with column)', <<~RUBY
      remove_index(:posts, column: :body)
    RUBY

    it_behaves_like 'accepts', 'remove_index (with two args)', <<~RUBY
      remove_index(:posts, :body)
    RUBY

    it_behaves_like 'offense', 'remove_index(without column)', <<~RUBY
      remove_index(:posts, name: :index_columns_on_body)
    RUBY
  end

  context 'when multiple databases' do
    it 'does not register an offense for reversible operation' do
      expect_no_offenses(<<~RUBY, 'db/animals_migrate/20250101010101_create_animals.rb')
        class CreateAnimals < ActiveRecord::Migration[7.0]
          def change
            create_table :animals
          end
        end
      RUBY
    end

    it 'registers an offense for irreversible operation' do
      expect_offense(<<~RUBY, 'db/animals_migrate/20250101010101_remove_animals.rb')
        class RemoveAnimals < ActiveRecord::Migration[7.0]
          def change
            drop_table :animals
            ^^^^^^^^^^^^^^^^^^^ drop_table(without block) is not reversible.
          end
        end
      RUBY
    end

    it 'does not register an offense for irreversible operation when migration file was migrated' do
      expect_no_offenses(<<~RUBY, 'db/animals_migrate/20190101010101_remove_animals.rb')
        class RemoveAnimals < ActiveRecord::Migration[7.0]
          def change
            drop_table :animals
          end
        end
      RUBY
    end
  end

  context 'when irreversible operation is used in `::` prefixed class definition' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, 'db/migrate/20250101010101_remove_animals.rb')
        class ::RemoveAnimals < ActiveRecord::Migration[7.0]
          def change
            drop_table :animals
            ^^^^^^^^^^^^^^^^^^^ drop_table(without block) is not reversible.
          end
        end
      RUBY
    end
  end
end
