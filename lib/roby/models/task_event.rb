module Roby
    module Models
        # Model-level API for task events
        module TaskEvent
            include MetaRuby::ModelAsClass

            # The task model this event is defined on
            # @return [Model<Task>]
            attr_accessor :task_model

            # If the event model defines a controlable event
            # By default, an event is controlable if the model
            # responds to #call
            def controlable?; respond_to?(:call) end

	    # Called by Task.update_terminal_flag to update the flag
	    attr_predicate :terminal?, true

            # @return [Symbol] the event name
            attr_accessor :symbol

            # Creates a new task event model
            def new_submodel(options)
                options = Kernel.validate_options options,
                    :task_model, :symbol, :command, :terminal

                submodel = super()
                submodel.task_model = options[:task_model]
                submodel.symbol     = options[:symbol]
                submodel.terminal   = options[:terminal]

                if command = options[:command]
                    if command.respond_to?(:call)
                        # check that the supplied command handler can take two arguments
                        check_arity(command, 2)
                        submodel.singleton_class.class_eval do
                            define_method(:call, &command)
                        end
                    else
                        submodel.singleton_class.class_eval do
                            def call(task, context) # :nodoc:
                                task.emit(symbol, *context)
                            end
                        end
                    end
                end

                submodel
            end
        end
    end
end
