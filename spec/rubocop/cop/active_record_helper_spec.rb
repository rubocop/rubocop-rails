# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ActiveRecordHelper, :isolated_environment do
  include FileHelper

  let(:cop) do
    Class.new.extend described_class
  end

  let(:schema_path) { 'db/schema.rb' }

  describe '#external_dependency_checksum' do
    subject { cop.external_dependency_checksum }

    context 'with db/schema.rb' do
      before do
        create_file(schema_path, <<~RUBY)
          ActiveRecord::Schema.define(version: 2020_04_08_082625) do
            create_table "articles" do |t|
              t.string "title", null: false
            end
          end
        RUBY
      end

      it { is_expected.to eq '1f263bed5ada8f2292ce7ceebd3c518bac3d2d1d' }
    end

    context 'with empty db/schema.rb' do
      before { create_empty_file(schema_path) }

      it { is_expected.to eq 'adc83b19e793491b1c6ea0fd8b46cd9f32e592fc' }
    end

    context 'without db/schema.rb' do
      it { is_expected.to be_nil }
    end
  end

  describe '#table_name' do
    subject { cop.table_name(class_node) }

    context 'when the class is simple' do
      let(:class_node) { parse_source(<<~RUBY).ast }
        class User
        end
      RUBY

      it { is_expected.to eq 'users' }
    end

    context 'when the self.table_name is set' do
      let(:class_node) { parse_source(<<~RUBY).ast }
        class Foo
          self.table_name = 'bar'
        end
      RUBY

      it { is_expected.to eq 'bar' }
    end

    context 'when the class is defined in a module' do
      let(:class_node) { parse_source(<<~RUBY).ast.each_child_node(:class).first }
        module Admin
          class User
          end
        end
      RUBY

      it { is_expected.to eq 'admin_users' }
    end

    context 'when the class is defined in nested modules' do
      let(:class_node) { parse_source(<<~RUBY).ast.each_descendant(:class).first }
        module Cop
          module Admin
            class User
            end
          end
        end
      RUBY

      it { is_expected.to eq 'cop_admin_users' }
    end

    context 'when the class is defined with compact style' do
      let(:class_node) { parse_source(<<~RUBY).ast }
        class Cop::Admin::User
        end
      RUBY

      it { is_expected.to eq 'cop_admin_users' }
    end
  end
end
