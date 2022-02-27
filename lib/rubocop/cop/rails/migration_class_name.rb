# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop makes sure that each migration file defines a migration class
      # whose name matches the file name.
      # (e.g. `20220224111111_create_users.rb` should define `CreateUsers` class.)
      #
      # @example
      #   # db/migrate/20220224111111_create_users.rb
      #
      #   # bad
      #   class SellBooks < ActiveRecord::Migration[7.0]
      #   end
      #
      #   # good
      #   class CreateUsers < ActiveRecord::Migration[7.0]
      #   end
      #
      class MigrationClassName < Base
        extend AutoCorrector

        MSG = 'Replace with `%<corrected_class_name>s` that matches the file name.'

        def on_class(node)
          snake_class_name = to_snakecase(node.identifier.source)

          return if snake_class_name == basename_without_timestamp

          corrected_class_name = to_camelcase(basename_without_timestamp)
          message = format(MSG, corrected_class_name: corrected_class_name)

          add_offense(node.identifier, message: message) do |corrector|
            corrector.replace(node.identifier, corrected_class_name)
          end
        end

        private

        def basename_without_timestamp
          filepath = processed_source.file_path
          basename = File.basename(filepath, '.rb')
          basename.sub(/\A\d+_/, '')
        end

        def to_camelcase(word)
          word.split('_').map(&:capitalize).join
        end

        def to_snakecase(word)
          word
            .gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr('-', '_')
            .downcase
        end
      end
    end
  end
end
