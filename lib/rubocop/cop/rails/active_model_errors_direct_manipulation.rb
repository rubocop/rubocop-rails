# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks direct manipulation of ActiveModel#errors as hash.
      # These operations are deprecated in Rails 6.1 and will not work in Rails 7.
      #
      # @example
      #   # bad
      #   user.errors[:name] << 'msg'
      #   user.errors.messages[:name] << 'msg'
      #
      #   # good
      #   user.errors.add(:name, 'msg')
      #
      #   # bad
      #   user.errors[:name].clear
      #   user.errors.messages[:name].clear
      #
      #   # good
      #   user.errors.delete(:name)
      #
      class ActiveModelErrorsDirectManipulation < Base
        MSG = 'Avoid manipulating ActiveModel errors as hash directly.'

        MANIPULATIVE_METHODS = ':<< :append :clear :collect! :compact! :concat '\
                               ':delete :delete_at :delete_if :drop :drop_while :fill :filter! :keep_if '\
                               ':flatten! :insert :map! :pop :prepend :push :reject! :replace :reverse! '\
                               ':rotate! :select! :shift :shuffle! :slice! :sort! :sort_by! :uniq! :unshift'

        BASE_NODE = {
          general: '{send ivar lvar}',
          model_file: '{nil? send ivar lvar}'
        }.freeze

        PATTERN = {
          root_manipulation: <<~PATTERN,
            (send
              (send
                (send %<base_node>s :errors)
                :[]
                ...)
              {#{MANIPULATIVE_METHODS}}
              ...)
          PATTERN
          root_assignment: <<~PATTERN,
            (send
              (send %<base_node>s :errors)
              :[]=
              ...)
          PATTERN
          messages_details_manipulation: <<~PATTERN,
            (send
              (send
                (send
                  (send %<base_node>s :errors)
                  {:messages :details})
                :[]
                ...)
              {#{MANIPULATIVE_METHODS}}
              ...)
          PATTERN
          messages_details_assignment: <<~PATTERN
            (send
              (send
                (send %<base_node>s :errors)
                {:messages :details})
              :[]=
              ...)
          PATTERN
        }.freeze

        BASE_NODE.each do |file_type, base_node_pattern|
          PATTERN.each do |pattern_type, pattern|
            node_matcher_name = "#{file_type}_on_#{pattern_type}?"

            def_node_matcher(
              node_matcher_name,
              format(pattern, base_node: base_node_pattern)
            )
          end
        end

        def on_send(node)
          file_type = file_type()

          PATTERN.each do |pattern_type, _pattern|
            add_offense(node) if send("#{file_type}_on_#{pattern_type}?", node)
          end
        end

        private

        def file_type
          filename = File.expand_path(processed_source.buffer.name)
          filename.include?('/models/') ? :model_file : :general
        end
      end
    end
  end
end
