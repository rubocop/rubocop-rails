# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ActiveRecordHelper, :isolated_environment do
  include FileHelper

  module RuboCop
    module Cop
      class Example < Cop
        include ActiveRecordHelper
      end
    end
  end

  let(:cop) do
    RuboCop::Cop::Example.new
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
end
