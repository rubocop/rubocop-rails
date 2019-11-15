# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks rake task definition without `environment` dependency.
      # `environment` dependency is important because it loads application code
      # for the rake task. The rake task cannot use application code, such as
      # models, without `environment` dependency.
      #
      # You can ignore the offense if the task satisfies at least one of the
      # following conditions:
      #
      # * The task does not need application code.
      # * The task invokes :environment task.
      #
      # @example
      #   # bad
      #   task :foo do
      #     do_something
      #   end
      #
      #   # good
      #   task foo: :environment do
      #     do_something
      #   end
      #
      class RakeEnvironment < Cop
        MSG = 'Set `:environment` task as a dependency to all rake task.'

        def_node_matcher :task_definition?, <<-PATTERN
          (send nil? :task ...)
        PATTERN

        def on_send(node)
          return unless task_definition?(node)
          return if task_name(node) == :default
          return if with_dependencies?(node)

          add_offense(node)
        end

        private

        def task_name(node)
          first_arg = node.arguments[0]
          case first_arg&.type
          when :sym, :str
            first_arg.value.to_sym
          when :hash
            return nil if first_arg.children.size != 1

            pair = first_arg.children.first
            key = pair.children.first
            case key.type
            when :sym, :str
              key.value.to_sym
            end
          end
        end

        def with_dependencies?(node)
          first_arg = node.arguments[0]
          return false unless first_arg

          if first_arg.hash_type?
            with_hash_style_dependencies?(first_arg)
          else
            task_args = node.arguments[1]
            return false unless task_args
            return false unless task_args.hash_type?

            with_hash_style_dependencies?(task_args)
          end
        end

        def with_hash_style_dependencies?(hash_node)
          deps = hash_node.pairs.first&.value
          return false unless deps

          case deps.type
          when :array
            !deps.values.empty?
          else
            true
          end
        end
      end
    end
  end
end
