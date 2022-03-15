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
        include MigrationsHelper

        MSG = 'Replace with `%<corrected_class_name>s` that matches the file name.'

        def on_class(node)
          return if in_migration?(node)

          snake_class_name = to_snakecase(node.identifier.source)

          basename = basename_without_timestamp_and_suffix
          return if snake_class_name == basename

          corrected_class_name = to_camelcase(basename)
          message = format(MSG, corrected_class_name: corrected_class_name)

          add_offense(node.identifier, message: message) do |corrector|
            corrector.replace(node.identifier, corrected_class_name)
          end
        end

        private

        def basename_without_timestamp_and_suffix
          filepath = processed_source.file_path
          basename = File.basename(filepath, '.rb')
          basename = remove_gem_suffix(basename)
          basename.sub(/\A\d+_/, '')
        end

        # e.g.: from `add_blobs.active_storage` to `add_blobs`.
        def remove_gem_suffix(file_name)
          file_name.sub(/\..+\z/, '')
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
