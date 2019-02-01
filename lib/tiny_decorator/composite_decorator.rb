module TinyDecorator
  #
  # Passing only decorator name, object will be decorated
  # ```
  #   extend TinyDecorator::CompositeDecorator
  #   decorated_by :default, 'DefaultDecorator'
  # ```
  #
  # Passing only 1 block param to #decorated_by
  # Execute block to get decorator name.
  # ```
  #   extend TinyDecorator::CompositeDecorator
  #   decorated_by :default, ->(record) { record.nil? ? 'NilDecorator' : 'DefaultDecorator' }
  #   decorated_by :default, ->(record, context) { record.in(context).nil? ? 'NilDecorator' : 'DefaultDecorator' }
  # ```
  #
  # Passing decorator name and 1 block param to #decorated_by
  # Execute block to determine should we decorate it or not
  # ```
  #   extend TinyDecorator::CompositeDecorator
  #   decorated_by :default, ->(record) { record.valid? ? 'ValidDecorator' : 'InvalidDecorator' }
  #   decorated_by :default, ->(record, context) { record.in(context).valid? ? 'ValidDecorator' : 'InvalidDecorator' }
  # ```
  #
  # For now, `:name` is redundant, but it's nice to have a friendly name for readbility and later usage
  #
  # Block may receive
  #   1 parameter is record to decorate OR
  #   2 parameters are record to decorate and context
  #
  # CompositeDecorator introduces a central conditional decorator manager.
  # It answer the questions: which decorater will be used in which conditions.
  # The decorator is a sub class of TinyDecorator::BaseDelegator (or draper decorator, but not recommend)
  # TinyDecorator::BaseDelegator will answer the question which attributes are decorated.
  #
  module CompositeDecorator
    # Decorate collection of objects, each object is decorate by `#decorate`
    # TODO: [AV] It's greate if with activerecord relationshop, we defer decorate until data retrieved.
    #       Using `map` will make data retrieval executes immediately
    def decorate_collection(records, context = {})
      Array(records).map do |record|
        decorate(record, context)
      end
    end

    # Decorate an object by defined `#decorated_by`
    def decorate(record, context = {})
      if instance_variable_get(:@_contexts)
        context = context.merge(instance_variable_get(:@_contexts).inject({}) do |carry, (context_name, context_block)|
          context[context_name] = context_block.call(record, context)

          carry
        end)
      end

      instance_variable_get(:@decorators).inject(record) do |carry, (name, value)|
        decorator = decorator_resolver(name, value, record, context)
        if decorator
          carry = begin
            const_get(decorator, false)
          rescue NameError
            Object.const_get(decorator, false)
          end.decorate(carry, context)
        end

        carry
      end
    end

    private

    def decorated_by(decorate_name, class_name, condition_block = nil)
      decorators = instance_variable_get(:@decorators) || {}
      decorators[decorate_name] = [class_name, condition_block]
      instance_variable_set(:@decorators, decorators)
    end

    def set_context(context_name, context_block)
      _contexts = instance_variable_get(:@_contexts) || {}
      _contexts[context_name] = context_block
      instance_variable_set(:@_contexts, _contexts)
    end

    # Resolve decorator class from #decorated_by definition
    # if 1st param is a block, evaluate it as decorator name
    # if 1st param isn't a block
    #     if no 2nd param, 1st param is decorator name
    #     if 2nd param exists, evaluate it as boolean to determine decorate or not
    def decorator_resolver(_name, value, record, context)
      if value[0].respond_to?(:call)
        ((value[0].arity == 1 && value[0].call(record)) || (value[0].arity == 2 && value[0].call(record, context)))
      elsif value[1].nil? || (value[1].arity == 1 && value[1].call(record)) || (value[1].arity == 2 && value[1].call(record, context))
        value[0]
      end
    end
  end
end
