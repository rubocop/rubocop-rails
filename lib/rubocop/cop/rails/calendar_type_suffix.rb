# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # It is convenient to follow a convention when naming database columns.
      # For calendar-type columns, a reasonable convention is:
      #
      # date     => * _on
      # datetime => *_at (e.g. timestamps)
      # time     => *_time
      #
      # @example
      #   # bad
      #   t.date "started_at"
      #   t.datetime "created_datetime"
      #   t.time "end_at"
      #
      #   # good
      #   t.date "started_on"
      #   t.datetime "created_at"
      #   t.time "end_time"
      #
      # "Inspired" by https://github.com/thoughtbot/guides/tree/master/rails
      class CalendarTypeSuffix < Cop
        MSG = 'Columns of type `%<type>s` should be named with a `%<suffix>s` suffix.'

        def_node_matcher :calendar_type?, '(send _ ${:date :datetime :time} (str $_) ...)'

        def on_send(node)
          calendar_type?(node) do |type, name|
            unless follows_convention?(type, name)
              add_offense(
                node,
                location: highlight_range(node),
                message: format(MSG, type: type, suffix: suffix_for(type))
              )
            end
          end
        end

        def relevant_file?(file)
          schema_file?(file) && super
        end

        private

        def schema_file?(file)
          File.basename(file) == 'schema.rb'
        end

        def follows_convention?(type, name)
          name.end_with?("_#{suffix_for(type)}")
        end

        def suffix_for(type)
          case type
          when :date then cop_config['DateSuffix']
          when :datetime then cop_config['DateTimeSuffix']
          when :time then cop_config['TimeSuffix']
          end
        end

        def highlight_range(node)
          node.loc.expression.with(
            end_pos: node.children[2].loc.expression.end_pos
          )
        end
      end
    end
  end
end
