# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks that Active Record queries use literal keys in all of
      # their conditions. Using dynamic keys in queries can make code
      # susceptible to SQL injection attacks.
      #
      # @example
      #   # bad
      #   Model.where("order_count > #{params[:orders]}")
      #   Model.having("order_count > #{params[:orders]}")
      #   Model.exists?("order_count > #{params[:orders]}")
      #
      #   # good
      #   Model.where('order_count > ?', params[:orders])
      #   Model.having('order_count > ?', params[:orders])
      #   Model.exists?('order_count > ?', params[:orders])
      #
      # @example EnforcedStyle: params (default)
      #   # bad
      #   Model.find_by(params['id'])
      #
      #   # good
      #   Model.find_by(id: params['id'])
      #   Model.find_by(Group.arel_table[:id].in([1, 2, 3]))
      #
      # @example EnforcedStyle: all
      #
      #   # bad
      #   Model.find_by(params['id'])
      #   # Value from Strong Parameters could still cause a SQLi.
      #   Model.find_by(model_params['id'])
      #   # Unfortunately there are false positives too.
      #   Model.find_by(Group.arel_table[:id].in([1, 2, 3]))
      #
      #   # good
      #   Model.find_by(id: params['id'])
      #   Model.find_by(id: model_params['id'])
      class UnsafeQueryCondition < Base
        include ConfigurableEnforcedStyle

        MSG = 'Avoid using non-literal keys in ActiveRecord conditions.'

        # This list of methods was created by reading through
        # https://guides.rubyonrails.org/active_record_querying.html and
        # https://github.com/rails/rails/tree/main/activerecord/lib/active_record/relation
        RESTRICT_ON_SEND = %i[
          not
          rewhere
          where

          create_with
          find_by
          find_by!
          find_or_create_by
          find_or_create_by!
          find_or_initialize_by
          find_or_initialize_by!

          exists?

          having
        ].freeze

        def_node_matcher :non_literal_condition?, <<~'PATTERN'
          (
            send _ _                             # Match `where` and `Model.find_by`
            ({dstr <begin ...> | send #matching_send?} ...)  # Match where(params[:id]) and where("#{method}")
          )
        PATTERN

        def_node_matcher :params?, '(send nil? :params)'

        def matching_send?(node)
          style == :all ? true : params?(node)
        end

        def on_send(node)
          return unless non_literal_condition?(node)

          add_offense(node)
        end
      end
    end
  end
end
