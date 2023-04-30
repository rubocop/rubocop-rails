# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::NotNullColumn, :config do
  let(:cop_config) { { 'Include' => nil } }

  context 'with add_column call' do
    context 'with null: false' do
      it 'reports an offense' do
        expect_offense(<<~RUBY)
          add_column :users, :name, :string, null: false
                                             ^^^^^^^^^^^ Do not add a NOT NULL column without a default value.
        RUBY
      end
    end

    context 'with null: false and default' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          add_column :users, :name, :string, null: false, default: ""
        RUBY
      end
    end

    context 'with null: false and default: nil' do
      it 'reports an offense' do
        expect_offense(<<~RUBY)
          add_column :users, :name, :string, null: false, default: nil
                                             ^^^^^^^^^^^ Do not add a NOT NULL column without a default value.
        RUBY
      end

      it 'does not register an offense for virtual columns' do
        expect_no_offenses(<<~RUBY)
          add_column :users, :height_in, :virtual, as: "height_cm / 2.54", null: false, default: nil
          add_column :users, :height_in, 'virtual', as: "height_cm / 2.54", null: false, default: nil
        RUBY
      end

      it 'does not register an offense for json columns' do
        expect_no_offenses(<<~RUBY)
          add_column :users, :metadata, :json, null: false
        RUBY
      end
    end

    context 'with null: true' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          add_column :users, :name, :string, null: true
        RUBY
      end
    end

    context 'without any options' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          add_column :users, :name, :string
        RUBY
      end
    end
  end

  context 'with change_column call' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        add_column :users, :name, :string
        User.update_all(name: "dummy")
        change_column :users, :name, :string, null: false
      RUBY
    end
  end

  context 'with create_table call' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class CreateUsersTable < ActiveRecord::Migration
          def change
            create_table :users do |t|
              t.string :name, null: false
              t.timestamps null: false
            end
          end
        end
      RUBY
    end
  end

  context 'with add_reference call' do
    context 'with null: false' do
      it 'reports an offense' do
        expect_offense(<<~RUBY)
          add_reference :products, :category, null: false
                                              ^^^^^^^^^^^ Do not add a NOT NULL column without a default value.
        RUBY
      end
    end

    context 'with default option' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          add_reference :products, :category, null: false, default: 1
        RUBY
      end
    end

    context 'without any options' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          add_reference :products, :category
        RUBY
      end
    end
  end
end
