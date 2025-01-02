# frozen_string_literal: true

module RuboCop
  module Cop
    # A mixin to return all of the class send nodes.
    module ClassElementsHelper
      def class_send_nodes(class_node)
        class_def = class_node.body

        return [] unless class_def

        if class_def.send_type?
          [class_def]
        else
          class_def.each_child_node(:send)
        end
      end

      def class_def_nodes(class_node)
        class_def = class_node.body

        return [] unless class_def

        if class_def.def_type?
          [class_def]
        else
          class_def.each_child_node(:def)
        end
      end
    end
  end
end
