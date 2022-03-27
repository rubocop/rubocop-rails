# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces the existence of mailer previews.
      #
      # @example
      #   # bad
      #   # app/mailer/user_mailer.rb
      #   class UserMailer < ApplicationMailer
      #     def welcome_email
      #     end
      #   end
      #
      #   # No file exists in mailer previews directory.
      #
      #   # good
      #   # app/mailer/user_mailer.rb
      #   class UserMailer < ApplicationMailer
      #     def welcome_email
      #     end
      #   end
      #
      #   # test/mailers/previews/user_mailer_preview.rb
      #   class UserMailer < ActionMailer::Preview
      #     def welcome_email
      #     end
      #   end
      #
      class MailerPreviews < Base
        include ParentClassMatchers
        include ClassElementsHelper
        include ParsingHelper
        include VisibilityHelp

        MSG = 'Add a mailer preview for `%<action_name>s`.'

        def on_class(node)
          return unless mailer_base_class?(node.parent_class)

          actions(node).each do |action_node|
            mailer_name = node.identifier.source
            action_name = action_node.method_name
            message = format(MSG, action_name: action_name)

            add_offense(action_node, message: message) unless preview_action_exists?(mailer_name, action_name)
          end
        end

        private

        def preview_action_exists?(mailer_name, action_name)
          preview_files(mailer_name).any? do |preview_path|
            if preview_path.exist?
              node = parse(preview_path, target_ruby_version)

              node&.class_type? &&
                mailer_preview_base_class?(node.parent_class) &&
                actions(node).map(&:method_name).include?(action_name)
            end
          end
        end

        def actions(class_node)
          class_def_nodes(class_node).select { |def_node| node_visibility(def_node) == :public }
        end

        def preview_files(class_name)
          path = Pathname.pwd
          Array(cop_config['PreviewPaths']).map do |preview_path|
            path.join(preview_path, "#{class_name.underscore}_preview.rb")
          end
        end
      end
    end
  end
end
