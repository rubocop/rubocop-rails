# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for Rake tasks without the `:environment` task
      # dependency. The `:environment` task loads application code for other
      # Rake tasks. Without it, tasks cannot make use of application code like
      # models.
      #
      # You can ignore the offense if the task satisfies at least one of the
      # following conditions:
      #
      # * The task does not need application code.
      # * The task invokes the `:environment` task.
      #
      # @safety
      #   Probably not a problem in most cases, but it is possible that calling `:environment` task
      #   will break a behavior. It's also slower. E.g. some task that only needs one gem to be
      #   loaded to run will run significantly faster without loading the whole application.
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
      class RakeEnvironment < Base
        extend AutoCorrector

        MSG = 'Include `:environment` task as a dependency for all Rake tasks.'

        def_node_matcher :task_definition?, <<~PATTERN
          (block $(send nil? :task ...) ...)
        PATTERN

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler, InternalAffairs/ItblockHandler
          task_definition?(node) do |task_method|
            return if task_name(task_method) == :default
            return if with_dependencies?(task_method)

            add_offense(task_method) do |corrector|
              autocorrect(corrector, task_method)
            end
          end
        end

        private

        def autocorrect(corrector, task_method)
          task_name, *task_arguments = task_method.arguments

          if task_arguments.empty?
            correct_task_name(corrector, task_name)
          else
            correct_task_arguments(corrector, task_arguments)
          end
        end

        def correct_task_name(corrector, task_name)
          if task_name.hash_type?
            correct_empty_dependencies(corrector, task_name)
          else
            corrector.replace(task_name, correct_task_dependency(task_name))
          end
        end

        def correct_task_arguments(corrector, task_arguments)
          if task_arguments.one?
            correct_single_task_argument(corrector, task_arguments.first)
          elsif task_arguments.all? { |argument| argument.type?(:sym, :str) }
            corrector.replace(task_arguments_range(task_arguments), task_arguments_dependency(task_arguments))
          end
        end

        def correct_single_task_argument(corrector, argument)
          if argument.hash_type?
            correct_empty_dependencies(corrector, argument)
          elsif argument.array_type?
            corrector.replace(argument, "#{argument.source} => :environment")
          elsif argument.type?(:sym, :str)
            corrector.replace(argument, task_arguments_dependency([argument]))
          end
        end

        def task_arguments_dependency(task_arguments)
          "[#{task_arguments.map(&:source).join(', ')}] => :environment"
        end

        def correct_empty_dependencies(corrector, hash_node)
          dependencies = hash_node.pairs.first&.value
          return unless dependencies&.array_type? && dependencies.values.empty?

          corrector.replace(dependencies, '[:environment]')
        end

        def task_arguments_range(task_arguments)
          task_arguments.first.source_range.join(task_arguments.last.source_range)
        end

        def correct_task_dependency(task_name)
          if task_name.sym_type?
            "#{task_name.source.delete(':|\'|"')}: :environment"
          else
            "#{task_name.source} => :environment"
          end
        end

        def task_name(node)
          first_arg = node.first_argument
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
          first_arg = node.first_argument
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
