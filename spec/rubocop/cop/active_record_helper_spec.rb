# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ActiveRecordHelper, :isolated_environment do
  include FileHelper

  let(:cop) do
    Class.new.extend described_class
  end

  let(:schema_path) { 'db/schema.rb' }

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
