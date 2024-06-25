# frozen_string_literal: true

module RuboCop
  module Cop
    # A mixin with predefined parent classes matchers
    module ParentClassMatchers
      extend NodePattern::Macros

      def_node_matcher :mailer_base_class?, <<~PATTERN
        {
          (const (const {nil? cbase} :ActionMailer) :Base)
          (const {nil? cbase} :ApplicationMailer)
        }
      PATTERN

      def_node_matcher :mailer_preview_base_class?, <<~PATTERN
        (const (const nil? :ActionMailer) :Preview)
      PATTERN
    end
  end
end
