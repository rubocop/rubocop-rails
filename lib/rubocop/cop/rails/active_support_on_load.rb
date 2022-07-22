# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for Rails framework classes that are patched directly instead of using Active Support load hooks. Direct
      # patching forcibly loads the framework referenced, using hooks defers loading until it's actually needed.
      #
      # @safety
      #   While using lazy load hooks is recommended, it changes the order in which is code is loaded and may reveal
      #   load order dependency bugs.
      #
      # @example
      #
      #   # bad
      #   ActiveRecord::Base.include(MyClass)
      #
      #   # good
      #   ActiveSupport.on_load(:active_record) { include MyClass }
      class ActiveSupportOnLoad < Base
        extend AutoCorrector

        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'
        RESTRICT_ON_SEND = %i[prepend include extend].freeze
        LOAD_HOOKS = {
          'ActionCable' => 'action_cable',
          'ActionCable::Channel::Base' => 'action_cable_channel',
          'ActionCable::Connection::Base' => 'action_cable_connection',
          'ActionCable::Connection::TestCase' => 'action_cable_connection_test_case',
          'ActionController::API' => 'action_controller',
          'ActionController::Base' => 'action_controller',
          'ActionController::TestCase' => 'action_controller_test_case',
          'ActionDispatch::IntegrationTest' => 'action_dispatch_integration_test',
          'ActionDispatch::Request' => 'action_dispatch_request',
          'ActionDispatch::Response' => 'action_dispatch_response',
          'ActionDispatch::SystemTestCase' => 'action_dispatch_system_test_case',
          'ActionMailbox::Base' => 'action_mailbox',
          'ActionMailbox::InboundEmail' => 'action_mailbox_inbound_email',
          'ActionMailbox::Record' => 'action_mailbox_record',
          'ActionMailbox::TestCase' => 'action_mailbox_test_case',
          'ActionMailer::Base' => 'action_mailer',
          'ActionMailer::TestCase' => 'action_mailer_test_case',
          'ActionText::Content' => 'action_text_content',
          'ActionText::Record' => 'action_text_record',
          'ActionText::RichText' => 'action_text_rich_text',
          'ActionView::Base' => 'action_view',
          'ActionView::TestCase' => 'action_view_test_case',
          'ActiveJob::Base' => 'active_job',
          'ActiveJob::TestCase' => 'active_job_test_case',
          'ActiveRecord::Base' => 'active_record',
          'ActiveStorage::Attachment' => 'active_storage_attachment',
          'ActiveStorage::Blob' => 'active_storage_blob',
          'ActiveStorage::Record' => 'active_storage_record',
          'ActiveStorage::VariantRecord' => 'active_storage_variant_record',
          'ActiveSupport::TestCase' => 'active_support_test_case'
        }.freeze

        def on_send(node)
          receiver, method, arguments = *node # rubocop:disable InternalAffairs/NodeDestructuring
          return unless receiver && (hook = LOAD_HOOKS[receiver.const_name])

          preferred = "ActiveSupport.on_load(:#{hook}) { #{method} #{arguments.source} }"
          add_offense(node, message: format(MSG, prefer: preferred, current: node.source)) do |corrector|
            corrector.replace(node, preferred)
          end
        end
      end
    end
  end
end
